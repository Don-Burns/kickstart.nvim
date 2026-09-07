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
        "b0o/schemastore.nvim",
        config = function()
            -- Schemas are now configured directly in init.lua via vim.lsp.config
            -- This plugin just provides the schema data
        end,
    }
}
