-- For "normal" vim setings
return {
    apply_options = function()
        -- Set <space> as the leader key
        -- See `:help mapleader`
        --  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
        vim.g.mapleader = " "
        vim.g.maplocalleader = " "
        -- [[ Setting options ]]

        -- See `:help vim.o`
        -- NOTE: You can change these options as you wish!

        -- Force there to be at least N lines above/below when scrolling
        vim.o.scrolloff = 15

        -- Set highlight on search
        vim.o.hlsearch = false

        -- Make line numbers default
        vim.wo.number = true

        -- Enable mouse mode
        vim.o.mouse = "a"

        -- Sync clipboard between OS and Neovim.
        --  Remove this option if you want your OS clipboard to remain independent.
        --  See `:help 'clipboard'`
        --  If having difficulty, install "xclip" on linux to ensure there is something that can take system clipboard
        --  to neovim
        vim.o.clipboard = "unnamedplus"

        -- Enable break indent
        vim.o.breakindent = true

        -- Save undo history
        vim.o.undofile = true

        -- Case-insensitive searching UNLESS \C or capital in search
        vim.o.ignorecase = true
        vim.o.smartcase = true

        -- Keep signcolumn on by default
        vim.wo.signcolumn = "yes"

        -- Decrease update time
        vim.o.updatetime = 250
        vim.o.timeoutlen = 300

        -- Set completeopt to have a better completion experience
        vim.o.completeopt = "menuone,noselect"

        -- NOTE: You should make sure your terminal supports this
        vim.o.termguicolors = true

        -- diagnostics
        vim.diagnostic.config({
            virtual_text = {
                -- source = "always",  -- Or "if_many"
                -- prefix = "●", -- Could be '■', '▎', 'x'
            },
            severity_sort = true,
            float = {
                source = "always", -- Or "if_many"
            },
        })
    end
}
