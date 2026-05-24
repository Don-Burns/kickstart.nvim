-- testing/specs/startup_spec.lua
-- Tests that Neovim starts without errors or warnings

local helpers = require("testing.helpers")

describe("Neovim startup", function()
    it("starts without errors or warnings in messages", function()
        -- Give plugins a moment to fully initialize
        vim.wait(2000)

        local messages = helpers.capture_messages()
        local lines = vim.split(messages, "\n")

        local error_lines = {}
        for _, line in ipairs(lines) do
            -- Check for vim error codes (E followed by digits and colon)
            if line:match("^E%d+:") then
                table.insert(error_lines, line)
            end
            -- Check for explicit error messages
            if line:match("^Error") or line:match("^ERROR") then
                table.insert(error_lines, line)
            end
            -- Check for "Failed to load" patterns from plugin loading
            if line:match("Failed to load") then
                table.insert(error_lines, line)
            end
        end

        local msg = "Found error messages on startup:\n" .. table.concat(error_lines, "\n")
        assert.are.equal(0, #error_lines, msg)
    end)

    it("loads lazy.nvim plugin manager", function()
        local ok, lazy = pcall(require, "lazy")
        assert.is_true(ok, "Failed to require lazy.nvim")
        assert.is_not_nil(lazy, "lazy module is nil")
    end)

    it("loads telescope", function()
        local ok, telescope = pcall(require, "telescope")
        assert.is_true(ok, "Failed to require telescope")
        assert.is_not_nil(telescope, "telescope module is nil")
    end)

    it("loads nvim-treesitter", function()
        local ok, ts = pcall(require, "nvim-treesitter")
        assert.is_true(ok, "Failed to require nvim-treesitter")
        assert.is_not_nil(ts, "nvim-treesitter module is nil")
    end)

    it("loads lspconfig", function()
        local ok, lspconfig = pcall(require, "lspconfig")
        assert.is_true(ok, "Failed to require lspconfig")
        assert.is_not_nil(lspconfig, "lspconfig module is nil")
    end)

    it("loads gitsigns", function()
        local ok, gitsigns = pcall(require, "gitsigns")
        assert.is_true(ok, "Failed to require gitsigns")
        assert.is_not_nil(gitsigns, "gitsigns module is nil")
    end)

    it("has leader key set to space", function()
        assert.are.equal(" ", vim.g.mapleader, "Expected mapleader to be space")
    end)
end)
