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

        -- DiffOrig command: view changes since file was loaded
        -- Useful after :recover to see what changed during recovery
        -- This is taken from what is suggested in nvim docs. `:h DiffOrig`
        vim.cmd([[
            command DiffOrig vert new | set buftype=nofile | read ++edit # | 0d_ | diffthis | wincmd p | diffthis
        ]])

        -- SwapExists autocmd: show workflow reminder when swap file detected
        vim.api.nvim_create_autocmd("SwapExists", {
            group = vim.api.nvim_create_augroup("SwapReminder", { clear = true }),
            callback = function()
                vim.notify(
                    "Swap file detected!\n\n"
                    .. "Workflow:\n"
                    .. "1. Press 'r' to recover from swap\n"
                    .. "2. Run :DiffOrig to see differences\n"
                    .. "3. Keep or discard based on changes",
                    vim.log.levels.WARN,
                    { timeout = 10000 }  -- 10 seconds before auto-dismiss
                )
            end,
        })
    end
}
