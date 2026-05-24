-- testing/specs/telescope_spec.lua
-- Tests for Telescope and Treesitter integration

local helpers = require("testing.helpers")

describe("Treesitter", function()
    local test_file = helpers.get_testing_path() .. "/codesamples/test.py"

    it("attaches parser to Python files", function()
        vim.cmd("edit " .. test_file)
        local bufnr = vim.api.nvim_get_current_buf()

        -- Wait for treesitter to attach (it's deferred via vim.defer_fn)
        local parser_attached = helpers.wait_for(function()
            local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
            return ok and parser ~= nil
        end, 10000)

        assert.is_true(parser_attached, "Treesitter parser did not attach to Python file")

        -- Verify it's a Python parser
        local parser = vim.treesitter.get_parser(bufnr)
        local lang = parser:lang()
        assert.are.equal("python", lang, "Expected Python parser, got: " .. tostring(lang))

        vim.cmd("bdelete!")
    end)

    it("provides syntax tree for Python", function()
        vim.cmd("edit " .. test_file)
        local bufnr = vim.api.nvim_get_current_buf()

        -- Wait for treesitter to attach
        helpers.wait_for(function()
            local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
            return ok and parser ~= nil
        end, 10000)

        -- Verify the parser can produce a syntax tree
        local parser = vim.treesitter.get_parser(bufnr)
        local trees = parser:parse()
        assert.is_true(#trees > 0, "Treesitter produced no syntax trees")

        -- Verify the tree has nodes (i.e., parsing worked)
        local root = trees[1]:root()
        assert.is_not_nil(root, "Treesitter syntax tree has no root node")
        assert.is_true(root:child_count() > 0, "Treesitter root node has no children")

        vim.cmd("bdelete!")
    end)
end)

describe("Telescope", function()
    it("find_files picker opens without error", function()
        -- Clear messages before test
        vim.cmd("messages clear")

        -- Open telescope find_files
        local ok, err = pcall(function()
            require("telescope.builtin").find_files({ cwd = helpers.get_config_path() })
        end)

        assert.is_true(ok, "Telescope find_files failed to open: " .. tostring(err))

        -- Wait a moment for the picker to render
        vim.wait(1000)

        -- Check that a telescope window is open
        local telescope_open = false
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.bo[buf].filetype
            if ft == "TelescopePrompt" or ft == "TelescopeResults" then
                telescope_open = true
                break
            end
        end

        assert.is_true(telescope_open, "Telescope picker window did not open")

        -- Close telescope
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
        vim.wait(500)

        -- Check no errors were produced
        local messages = helpers.capture_messages()
        assert.is_nil(messages:match("^E%d+:"), "Telescope produced vim errors: " .. messages)
    end)

    it("live_grep picker opens without error", function()
        vim.cmd("messages clear")

        local ok, err = pcall(function()
            require("telescope.builtin").live_grep({ cwd = helpers.get_config_path() })
        end)

        assert.is_true(ok, "Telescope live_grep failed to open: " .. tostring(err))

        vim.wait(1000)

        -- Close telescope
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
        vim.wait(500)

        local messages = helpers.capture_messages()
        assert.is_nil(messages:match("^E%d+:"), "Telescope live_grep produced vim errors: " .. messages)
    end)

    it("treesitter picker (find symbols) opens without error", function()
        -- Open a Python file first so treesitter symbols are available
        local test_file = helpers.get_testing_path() .. "/codesamples/test.py"
        vim.cmd("edit " .. test_file)

        -- Wait for treesitter
        helpers.wait_for(function()
            local ok, parser = pcall(vim.treesitter.get_parser, 0)
            return ok and parser ~= nil
        end, 10000)

        vim.cmd("messages clear")

        local ok, err = pcall(function()
            require("telescope.builtin").treesitter()
        end)

        assert.is_true(ok, "Telescope treesitter picker failed to open: " .. tostring(err))

        vim.wait(1000)

        -- Close telescope
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
        vim.wait(500)

        local messages = helpers.capture_messages()
        assert.is_nil(messages:match("^E%d+:"), "Telescope treesitter produced vim errors: " .. messages)

        vim.cmd("bdelete!")
    end)

    it("switches to a different file via find_files without errors", function()
        local codesamples = helpers.get_testing_path() .. "/codesamples"
        local initial_file = codesamples .. "/test.py"
        local target_file = codesamples .. "/docker-compose.yaml"

        -- Open initial Python file
        vim.cmd("edit " .. initial_file)
        local initial_bufnr = vim.api.nvim_get_current_buf()

        -- Wait for LSP to attach to ensure full initialization
        helpers.wait_for_lsp(initial_bufnr, 15000)
        vim.wait(2000)

        -- Clear messages before the switch
        vim.cmd("messages clear")

        -- Open Telescope find_files scoped to codesamples, pre-filling query
        local open_ok, open_err = pcall(function()
            require("telescope.builtin").find_files({
                cwd = codesamples,
                default_text = "docker",
            })
        end)
        assert.is_true(open_ok, "Telescope find_files failed to open: " .. tostring(open_err))

        -- Wait for picker to render and results to populate
        vim.wait(2000)

        -- Find the telescope prompt buffer
        local prompt_bufnr = nil
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "TelescopePrompt" then
                prompt_bufnr = buf
                break
            end
        end
        assert.is_not_nil(prompt_bufnr, "Telescope prompt buffer not found")

        -- Select the first result (confirms file switch)
        local actions = require("telescope.actions")
        local select_ok, select_err = pcall(actions.select_default, prompt_bufnr)
        assert.is_true(select_ok, "Telescope select_default failed: " .. tostring(select_err))

        -- Wait for the new buffer to fully load (LSP/treesitter may attach)
        vim.wait(5000)

        -- Verify we switched to the target file
        local current_file = vim.api.nvim_buf_get_name(0)
        assert.are.equal(
            target_file,
            current_file,
            "Expected to switch to " .. target_file .. " but got: " .. current_file
        )

        -- Check that the buffer actually changed
        assert.are_not.equal(initial_bufnr, vim.api.nvim_get_current_buf(), "Buffer did not change after file switch")

        -- Check messages for any errors produced during the switch
        local messages = helpers.capture_messages()
        local error_patterns = {
            "E%d+:",           -- Vim error codes
            "Error",           -- Explicit error messages
            "stack traceback", -- Lua runtime errors
            "Failed",          -- Module/plugin load failures
        }
        for _, pattern in ipairs(error_patterns) do
            local match = messages:match(pattern)
            if match then
                -- Ignore known benign messages
                local is_benign = messages:match("%[nvim%-treesitter/install") -- treesitter install messages
                if not is_benign then
                    assert.is_nil(match, "Error detected after file switch.\nPattern: " .. pattern .. "\nMessages:\n" .. messages)
                end
            end
        end

        vim.cmd("bdelete!")
    end)

    it("switches back to original file without error accumulation", function()
        local codesamples = helpers.get_testing_path() .. "/codesamples"
        local file_a = codesamples .. "/docker-compose.yaml"
        local file_b = codesamples .. "/test.py"

        -- Start on file A
        vim.cmd("edit " .. file_a)
        vim.wait(3000)

        -- Switch to file B via telescope
        vim.cmd("messages clear")
        require("telescope.builtin").find_files({
            cwd = codesamples,
            default_text = "test.py",
        })
        vim.wait(2000)

        local prompt_bufnr = nil
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "TelescopePrompt" then
                prompt_bufnr = buf
                break
            end
        end
        assert.is_not_nil(prompt_bufnr, "Telescope prompt not found for first switch")
        pcall(require("telescope.actions").select_default, prompt_bufnr)
        vim.wait(5000)

        -- Verify we're on file B
        assert.are.equal(file_b, vim.api.nvim_buf_get_name(0), "First switch failed")

        -- Now switch back to file A
        vim.cmd("messages clear")
        require("telescope.builtin").find_files({
            cwd = codesamples,
            default_text = "docker",
        })
        vim.wait(2000)

        prompt_bufnr = nil
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "TelescopePrompt" then
                prompt_bufnr = buf
                break
            end
        end
        assert.is_not_nil(prompt_bufnr, "Telescope prompt not found for second switch")
        pcall(require("telescope.actions").select_default, prompt_bufnr)
        vim.wait(5000)

        -- Verify we're back on file A
        assert.are.equal(file_a, vim.api.nvim_buf_get_name(0), "Second switch (back) failed")

        -- Check no errors accumulated across both switches
        local messages = helpers.capture_messages()
        local error_patterns = {
            "E%d+:",
            "Error",
            "stack traceback",
            "Failed",
        }
        for _, pattern in ipairs(error_patterns) do
            local match = messages:match(pattern)
            if match then
                local is_benign = messages:match("%[nvim%-treesitter/install")
                if not is_benign then
                    assert.is_nil(match, "Error after round-trip switch.\nPattern: " .. pattern .. "\nMessages:\n" .. messages)
                end
            end
        end

        vim.cmd("%bdelete!")
    end)
end)
