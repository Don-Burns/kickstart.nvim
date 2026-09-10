return {
    "github/copilot.vim",
    init = function()
        vim.g.copilot_no_tab_map = true
        vim.g.copilot_filetypes = {
            ["*"] = true,
            -- ["javascript"] = true,
            -- ["typescript"] = true,
            -- ["lua"] = false,
            -- ["rust"] = true,
            -- ["c"] = true,
            -- ["c#"] = true,
            -- ["c++"] = true,
            -- ["go"] = true,
            -- ["python"] = true,
        }
    end,
    config = function()
        vim.keymap.set("i", "<C-l>", 'copilot#Accept("<CR>")', {
            expr = true,
            replace_keycodes = false,
            silent = true,
        })
    end,
}
