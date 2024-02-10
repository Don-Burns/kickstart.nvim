-- Lsp plugins and config
return {
    -- community null ls package for non-lsp progs like mypy
    "nvimtools/none-ls.nvim",

    dependencies = {
        -- Installs the needed programs with mason
        "williamboman/mason.nvim",
        "jay-babu/mason-null-ls.nvim",
        "davidmh/cspell.nvim", -- extension for cspell to work with null-ls
    },
    config = function()
        local null_ls = require("null-ls")
        local cspell = require("cspell")

        null_ls.setup({
            sources = {
                null_ls.builtins.diagnostics.mypy.with({
                    extra_args = { "--strict" },
                }),
                -- spelling diagnostics and code actions
                cspell.diagnostics.with({
                    -- change level of the diagnostic
                    diagnostics_postprocess = function(diagnostic)
                        diagnostic.severity = vim.diagnostic.severity.INFO
                    end
                }),
                cspell.code_actions,
            },
            -- determine if none-ls should run on current buffer
            should_attach = function(bufnr)
                local buff_name = vim.api.nvim_buf_get_name(bufnr)
                return not buff_name:match("^git://")
            end,
            on_attach = require("custom.keybinds").lsp_on_attach_binds,
        })
        require("mason-null-ls").setup({
            ensure_installed = nil,
            automatic_installation = true,
        })
    end,

}
