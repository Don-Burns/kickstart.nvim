-- testing/specs/highlight_spec.lua
-- Tests for the Python template-brace highlighting (lua/custom/plugins/theme.lua)

local helpers = require("testing.helpers")

local NS_NAME = "python_template_braces"

--- Get extmarks set by the template-brace highlighter for a buffer
---@param bufnr integer
---@return table[] list of { row, col, end_row, end_col, text }
local function get_template_brace_marks(bufnr)
    local ns = vim.api.nvim_create_namespace(NS_NAME)
    local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })
    local result = {}
    for _, m in ipairs(marks) do
        local row, col, details = m[2], m[3], m[4]
        local lines = vim.api.nvim_buf_get_lines(bufnr, row, details.end_row + 1, false)
        lines[1] = lines[1]:sub(col + 1)
        lines[#lines] = lines[#lines]:sub(1, details.end_col - (row == details.end_row and col or 0))
        table.insert(result, {
            row = row,
            col = col,
            end_row = details.end_row,
            end_col = details.end_col,
            text = table.concat(lines, "\n"),
        })
    end
    return result
end

--- Open a buffer with given lines as a python filetype and wait for highlights
--- Uses a real temp file (not a scratch buffer) since LSP clients misbehave
--- on unnamed buffers, which can interfere with FileType-triggered setup.
---@param lines string[]
---@return integer bufnr
---@return string tmp_file path, so the caller can clean it up
local function open_python_buffer(lines)
    local tmp_file = vim.fn.tempname() .. ".py"
    local file = io.open(tmp_file, "w")
    file:write(table.concat(lines, "\n") .. "\n")
    file:close()

    vim.cmd("edit " .. tmp_file)
    local bufnr = vim.api.nvim_get_current_buf()
    -- FileType autocmd triggers highlight_buf synchronously
    vim.wait(200)
    return bufnr, tmp_file
end

describe("Python template brace highlighting", function()
    local tmp_file

    after_each(function()
        pcall(vim.cmd, "bdelete!")
        if tmp_file then
            vim.fn.delete(tmp_file)
            tmp_file = nil
        end
    end)

    it("highlights {content} inside plain strings on the sample file", function()
        local test_file = helpers.get_testing_path() .. "/codesamples/test.py"
        vim.cmd("edit " .. test_file)
        local bufnr = vim.api.nvim_get_current_buf()
        vim.wait(200)

        local marks = get_template_brace_marks(bufnr)
        local texts = {}
        for _, m in ipairs(marks) do
            table.insert(texts, m.text)
        end

        assert.is_true(#marks > 0, "Expected at least one template-brace highlight")
        assert.is_true(
            vim.tbl_contains(texts, "{variable}"),
            "Expected {variable} to be highlighted. Got: " .. vim.inspect(texts)
        )
    end)

    it("highlights {content} in a plain (non f-) string", function()
        local bufnr
        bufnr, tmp_file = open_python_buffer({ 'template_string = "hello {my_var}"' })
        local marks = get_template_brace_marks(bufnr)

        assert.are.equal(1, #marks, "Expected exactly one highlight")
        assert.are.equal("{my_var}", marks[1].text)
    end)

    it("does NOT highlight braces inside f-strings", function()
        local bufnr
        bufnr, tmp_file = open_python_buffer({ 'f_string = f"hello {variable}"' })
        local marks = get_template_brace_marks(bufnr)

        assert.are.equal(0, #marks, "f-strings should be left untouched")
    end)

    it("does NOT highlight braces in dict/set literals", function()
        local bufnr
        bufnr, tmp_file = open_python_buffer({ 'd = {"a": {"a": {}}}' })
        local marks = get_template_brace_marks(bufnr)

        assert.are.equal(0, #marks, "Dict/set literal braces are not inside a string and must be ignored")
    end)

    it("highlights a multi-line template spanning several lines", function()
        local bufnr
        bufnr, tmp_file = open_python_buffer({
            'multi = """',
            "hello {my_var}",
            "and {",
            "  another_var",
            "}",
            '"""',
        })
        local marks = get_template_brace_marks(bufnr)
        local texts = {}
        for _, m in ipairs(marks) do
            table.insert(texts, m.text)
        end

        assert.is_true(
            vim.tbl_contains(texts, "{my_var}"),
            "Expected {my_var} to be highlighted. Got: " .. vim.inspect(texts)
        )
        assert.is_true(
            vim.tbl_contains(texts, "{\n  another_var\n}"),
            "Expected multi-line brace span to be highlighted. Got: " .. vim.inspect(texts)
        )
    end)
end)
