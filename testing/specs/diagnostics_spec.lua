-- testing/specs/diagnostics_spec.lua
-- Snapshot tests for Python diagnostics (ruff, mypy, cspell)

local helpers = require("testing.helpers")

describe("Python diagnostics", function()
    local bufnr
    local test_file = helpers.get_testing_path() .. "/codesamples/test.py"

    before_each(function()
        -- Open the test Python file
        vim.cmd("edit " .. test_file)
        bufnr = vim.api.nvim_get_current_buf()
    end)

    after_each(function()
        -- Close the buffer without saving
        vim.cmd("bdelete!")
    end)

    it("matches expected diagnostics snapshot for test.py", function()
        -- Wait for LSP clients to attach
        local lsp_attached = helpers.wait_for_lsp(bufnr, 20000)
        assert.is_true(lsp_attached, "LSP clients did not attach within timeout")

        -- Wait for diagnostics to populate
        -- We expect multiple diagnostics from ruff, mypy, and cspell
        local has_diagnostics = helpers.wait_for_diagnostics(bufnr, 45000, 3)
        assert.is_true(has_diagnostics, "Diagnostics did not appear within timeout")

        -- Give a bit more time for all sources to report
        -- (mypy can be slow, cspell runs async)
        vim.wait(5000)

        -- Get all diagnostics for the buffer
        local diagnostics = vim.diagnostic.get(bufnr)
        assert.is_true(#diagnostics > 0, "Expected at least one diagnostic")

        -- Format diagnostics to stable text representation
        local formatted = helpers.format_diagnostics(diagnostics)

        -- Compare against snapshot
        local match, diff = helpers.assert_snapshot("test_py_diagnostics.txt", formatted)
        assert.is_true(match, diff or "Snapshot mismatch")
    end)

    it("reports diagnostics from multiple sources", function()
        -- Wait for LSP and diagnostics
        helpers.wait_for_lsp(bufnr, 20000)
        helpers.wait_for_diagnostics(bufnr, 45000, 3)
        vim.wait(5000)

        local diagnostics = vim.diagnostic.get(bufnr)
        local sources = {}
        for _, d in ipairs(diagnostics) do
            if d.source then
                sources[d.source] = true
            end
        end

        -- We expect diagnostics from at least ruff
        -- mypy and cspell may or may not be available in all environments
        assert.is_true(
            sources["Ruff"] or sources["ruff"],
            "Expected diagnostics from ruff. Sources found: " .. vim.inspect(vim.tbl_keys(sources))
        )
    end)
end)
