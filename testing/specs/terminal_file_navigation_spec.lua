local function set_terminal_line(bufnr, text, cursor_text)
    vim.bo[bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { text })
    local col = cursor_text and assert(text:find(cursor_text, 1, true)) - 1 or 0
    vim.api.nvim_win_set_cursor(0, { 1, col })
end

local function press(key)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "xt", false)
end

local function toggle_terminal()
    press("<F12>")
end

describe("Terminal file navigation", function()
    local tmp_dir
    local target
    local markdown_target

    -- Set up an editor window and the dedicated terminal used by each test.
    before_each(function()
        tmp_dir = vim.fn.tempname()
        vim.fn.mkdir(tmp_dir, "p")
        target = tmp_dir .. "/other.py"
        local file = assert(io.open(target, "w"))
        file:write("first\nsecond\nthird\n")
        file:close()
        markdown_target = tmp_dir .. "/README.md"
        file = assert(io.open(markdown_target, "w"))
        file:write("# Readme\n\nContent\n")
        file:close()

        -- Open a new buffer to ensure the terminal opens in a clean state.
        vim.cmd("enew")
        vim.cmd("normal! \"_dd")
        toggle_terminal()
        vim.wait(100)
    end)

    -- Close the terminal and remove temporary buffers/files so tests stay isolated.
    after_each(function()
        toggle_terminal()
        vim.cmd("%bdelete!")
        vim.fn.delete(tmp_dir, "rf")
    end)

    it("opens a Python traceback file and jumps to its line", function()
        local terminal_buf = vim.api.nvim_get_current_buf()
        assert.are.equal("terminal", vim.bo[terminal_buf].buftype)

        set_terminal_line(terminal_buf, string.format('File "%s", line 2', target), target)
        vim.cmd("normal gF")

        assert.are.equal(target, vim.api.nvim_buf_get_name(0))
        assert.are.equal(2, vim.api.nvim_win_get_cursor(0)[1])
    end)

    it("opens a plain Markdown file path", function()
        local terminal_buf = vim.api.nvim_get_current_buf()
        set_terminal_line(terminal_buf, markdown_target)
        vim.cmd("normal gf")

        assert.are.equal(markdown_target, vim.api.nvim_buf_get_name(0))
    end)

    it("opens a plain Markdown file path with gF", function()
        local terminal_buf = vim.api.nvim_get_current_buf()
        set_terminal_line(terminal_buf, markdown_target .. ":2", markdown_target)
        vim.cmd("normal gF")

        assert.are.equal(markdown_target, vim.api.nvim_buf_get_name(0))
        assert.are.equal(2, vim.api.nvim_win_get_cursor(0)[1])
    end)
end)
