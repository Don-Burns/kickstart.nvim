-- Lsp plugins and config
return {
    -- community null ls package for non-lsp progs like mypy
    "nvimtools/none-ls.nvim",

    dependencies = {
        -- Installs the needed programs with mason
        "williamboman/mason.nvim",
        "jay-babu/mason-null-ls.nvim",
    },
    config = function()
        local null_ls = require("null-ls")

        null_ls.setup({
            sources = {
                null_ls.builtins.diagnostics.mypy,
                null_ls.builtins.formatting.codespell,
            },
            -- determine if none-ls should run on current buffer
            should_attach = function(bufnr)
                return not vim.api.nvim_buf_get_name(bufnr):match("^git://")
            end,
        })
        require("mason-null-ls").setup({
            ensure_installed = nil,
            automatic_installation = true,
        })
    end
}
