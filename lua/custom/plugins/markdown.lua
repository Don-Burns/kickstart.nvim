return {
    -- nicer viewing in editor
    {
        "MeanderingProgrammer/render-markdown.nvim",
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
        -- I have devicons already, so continue to use
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            completions = { lsp = { enabled = true } }
        },
        config = function(_, opts)
            local render_markdown = require("render-markdown")
            render_markdown.setup(opts)

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "markdown",
                callback = function(args)
                    -- this assumed <leader>T is my toggle section
                    vim.keymap.set("n", "<leader>Tm", render_markdown.buf_toggle, {
                        buffer = args.buf,
                        desc = "Markdown: Toggle rendering",
                    })
                    vim.keymap.set("n", "<leader>Tp", "<Cmd>MarkdownPreviewToggle<CR>", {
                        buffer = args.buf,
                        desc = "Markdown: Toggle browser preview",
                    })
                end,
            })
        end,
    },
    -- web preview
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = function()
            vim.cmd [[Lazy load markdown-preview.nvim]]
            vim.fn["mkdp#util#install"]()
        end,
    }
}
