-- testing/specs/format_spec.lua
-- Tests that format-on-save works correctly

local helpers = require("testing.helpers")

describe("Format on save", function()
    local tmp_dir = vim.fn.tempname()
    local tmp_file

    before_each(function()
        -- Create a fresh temp directory for each test
        tmp_dir = vim.fn.tempname()
        vim.fn.mkdir(tmp_dir, "p")
        tmp_file = tmp_dir .. "/test_format.py"
    end)

    after_each(function()
        -- Clean up
        pcall(vim.cmd, "bdelete!")
        vim.fn.delete(tmp_dir, "rf")
    end)

    it("formats Python files on save via LSP", function()
        -- Write an unformatted Python file
        -- ruff format will fix: trailing whitespace, missing newline at end,
        -- inconsistent spacing around operators
        local unformatted = table.concat({
            "import os",
            "import sys",
            "from pathlib import Path",
            "",
            "",
            "",
            "def   foo(  ):",
            "    x=1+2",
            "    y =    'hello'",
            "    return x",
            "",
        }, "\n")

        local file = io.open(tmp_file, "w")
        assert.is_not_nil(file, "Failed to create temp file")
        file:write(unformatted)
        file:close()

        -- Open the file in Neovim
        vim.cmd("edit " .. tmp_file)
        local bufnr = vim.api.nvim_get_current_buf()

        -- Wait for LSP to attach (ruff provides formatting)
        local lsp_attached = helpers.wait_for_lsp(bufnr, 20000)
        assert.is_true(lsp_attached, "LSP client did not attach within timeout")

        -- Wait a moment for the formatting autocmd to be set up
        vim.wait(2000)

        -- Save the file (triggers BufWritePre -> format)
        vim.cmd("write")

        -- Wait for async format to complete
        vim.wait(2000)

        -- Read the file back
        local formatted_file = io.open(tmp_file, "r")
        assert.is_not_nil(formatted_file, "Failed to read formatted file")
        local formatted_content = formatted_file:read("*a")
        formatted_file:close()

        -- The formatted content should differ from the original unformatted content
        assert.are_not.equal(
            unformatted,
            formatted_content,
            "File was not formatted on save - content is unchanged"
        )

        -- Specific checks: ruff format should fix spacing issues
        -- x=1+2 should become x = 1 + 2
        assert.is_nil(
            formatted_content:match("x=1%+2"),
            "Expected 'x=1+2' to be reformatted with spaces around operators"
        )
    end)

    it("respects ToggleAutoFormat to disable formatting", function()
        -- Write an unformatted file
        local unformatted = table.concat({
            "def   bar(  ):",
            "    x=1+2",
            "    return x",
            "",
        }, "\n")

        local file = io.open(tmp_file, "w")
        file:write(unformatted)
        file:close()

        -- Open the file
        vim.cmd("edit " .. tmp_file)
        local bufnr = vim.api.nvim_get_current_buf()

        -- Wait for LSP
        helpers.wait_for_lsp(bufnr, 20000)
        vim.wait(2000)

        -- Disable autoformat
        vim.cmd("ToggleAutoFormat")

        -- Rewrite the unformatted content (in case first save formatted it)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(unformatted, "\n"))

        -- Save
        vim.cmd("write")
        vim.wait(1000)

        -- Read back - should remain unformatted
        local result_file = io.open(tmp_file, "r")
        local result_content = result_file:read("*a")
        result_file:close()

        -- The poorly formatted "x=1+2" should still be present
        assert.is_not_nil(
            result_content:match("x=1%+2"),
            "Expected formatting to be disabled but file was formatted"
        )

        -- Re-enable autoformat for other tests
        vim.cmd("ToggleAutoFormat")
    end)
end)
