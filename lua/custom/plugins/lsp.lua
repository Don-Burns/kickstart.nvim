-- Lsp plugins and config
return {
    {
        "ThePrimeagen/refactoring.nvim",
        dependencies = {
            "lewis6991/async.nvim",
        },
        config = function()
            require("refactoring").setup({
                prompt_func_return_type = {
                    go = false,
                    java = false,

                    cpp = false,
                    c = false,
                    h = false,
                    hpp = false,
                    cxx = false,
                },
                prompt_func_param_type = {
                    go = false,
                    java = false,

                    cpp = false,
                    c = false,
                    h = false,
                    hpp = false,
                    cxx = false,
                },
                -- overriding extract statement for go
                -- leaving comment of this here as breadcrumbs for future reference
                -- extract_var_statements = {
                --     go = "%s := %s // extracted woo hoo"
                -- },
                printf_statements = {},
                print_var_statements = {},
                show_success_message = true, -- shows a message with information about the refactor on success
                -- i.e. [Refactor] Inlined 3 variable occurrences
            })
        end,
    },
    {
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
                    -- python
                    null_ls.builtins.diagnostics.mypy.with({
                        extra_args = { "--strict" },
                        dynamic_command = function(params)
                            local venv = vim.fn.getcwd() .. "/.venv/bin/mypy"
                            if vim.fn.executable(venv) == 1 then
                                return venv
                            end
                            if vim.env.VIRTUAL_ENV then
                                local venv_bin = vim.env.VIRTUAL_ENV .. "/bin/mypy"
                                if vim.fn.executable(venv_bin) == 1 then
                                    return venv_bin
                                end
                            end
                            return "mypy"
                        end,
                    }),
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

    },

    {
        "b0o/schemastore.nvim",
        config = function()
            -- Schemas are now configured directly in init.lua via vim.lsp.config
            -- This plugin just provides the schema data
        end,
    }
}
