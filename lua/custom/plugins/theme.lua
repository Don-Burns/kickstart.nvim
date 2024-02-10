return {
    "AstroNvim/astrotheme",
    lazy = false,
    priority = 1000,
    config = function()
        local theme = require("astrotheme")
        theme.setup({
            palette = "astrodark", -- String of the default palette to use when calling `:colorscheme astrotheme`
            background = {         -- :h background, palettes to use when using the core vim background colors
                light = "astrolight",
                dark = "astrodark",
            },

            style = {
                transparent = false,         -- Bool value, toggles transparency.
                inactive = true,             -- Bool value, toggles inactive window color.
                float = true,                -- Bool value, toggles floating windows background colors.
                neotree = true,              -- Bool value, toggles neo-trees background color.
                border = true,               -- Bool value, toggles borders.
                title_invert = true,         -- Bool value, swaps text and background colors.
                italic_comments = true,      -- Bool value, toggles italic comments.
                simple_syntax_colors = true, -- Bool value, simplifies the amounts of colors used for syntax highlighting.
            },


            termguicolors = true,    -- Bool value, toggles if termguicolors are set by AstroTheme.

            terminal_color = true,   -- Bool value, toggles if terminal_colors are set by AstroTheme.

            plugin_default = "auto", -- Sets how all plugins will be loaded
            -- "auto": Uses lazy / packer enabled plugins to load highlights.
            -- true: Enables all plugins highlights.
            -- false: Disables all plugins.

            plugins = { -- Allows for individual plugin overrides using plugin name and value from above.
                ["bufferline.nvim"] = false,
            },

            palettes = {
                global = { -- Globally accessible palettes, theme palettes take priority.
                    constants = "#0A7FFF",
                    comments = "#32780a",
                    identifiers = "#FFFFFF",
                    classes = "#05BA8C",
                    functions = "#FFC50A",
                    numbers = "#5135E2",
                    strings = "#B42233",
                    error = "#F40000",
                },
                astrodark = {               -- Extend or modify astrodarks palette colors
                    ui = {
                        red = "#F40000",    -- Overrides astrodarks red UI color e.g. error messages in lsp
                        accent = "#CC83E3", -- Changes the accent color
                        base = "#06021A",   -- Changes the base/main background color
                    },
                    syntax = {
                        -- see modify_hl_groups function below
                    },
                    -- my_color = "#000000", -- Overrides global.my_color

                },
            },

            highlights = {
                -- for list of what the available highlight categories are see: https://github.com/AstroNvim/astrotheme/blob/main/lua/astrotheme/groups/syntax.lua
                -- May need to adjust for the commit I am working off of
                global = { -- Add or modify hl groups globally, theme specific hl groups take priority.
                    modify_hl_groups = function(highlight, color)
                    end,
                    -- ["@String"] = { fg = "#ff00ff", bg = "NONE" },
                },
                astrodark = {
                    -- first parameter is the highlight table and the second parameter is the color palette table
                    modify_hl_groups = function(highlight, color) -- modify_hl_groups function allows you to modify hl groups,
                        -- Comments
                        highlight.Comment.fg = color.comments     -- this colour is defined above in palettes
                        highlight.Comment.italic = true

                        -- Variables
                        highlight.Identifier.fg = color.identifiers

                        -- Constants
                        highlight.Constant.fg = color.constants

                        -- Functions
                        highlight.Function.fg = color.functions

                        -- Classes/Structs
                        highlight.Structure.fg = color.classes
                        highlight.Type.fg = color.classes
                        highlight.Typedef.fg = color.classes
                        highlight.StorageClass.fg = color.classes

                        -- Numbers/Ints
                        highlight.Number.fg = color.numbers

                        -- Strings
                        highlight.String.fg = color.strings
                    end,
                    -- ["@String"] = { fg = "#ff00ff", bg = "NONE" },
                },
            },
        })
        theme.load()
    end,
}
