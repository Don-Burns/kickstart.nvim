return {
    "github/copilot.vim",
    init = function()
        vim.g.copilot_assume_mapped = true
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
}
