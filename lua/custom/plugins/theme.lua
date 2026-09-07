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

                        -- Diff highlighting - make it pop
                        highlight.DiffAdd = { fg = "#22C55E", bg = "#1A3A1A", bold = true }
                        highlight.DiffDelete = { fg = "#EF4444", bg = "#3A1A1A", bold = true }
                        highlight.DiffChange = { fg = "#3B82F6", bg = "#1A2A3A", bold = true }
                        highlight.DiffText = { fg = "#FBBF24", bg = "#2A2410", bold = true }
                    end,
                    -- ["@String"] = { fg = "#ff00ff", bg = "NONE" },
                },
            },
        })
        theme.load()

        -- Highlight {content} inside plain Python strings blue (f-strings are
        -- left alone, they already get their own `interpolation` highlighting).
        -- Python's treesitter grammar has no sub-node for braces inside plain
        -- strings, so we query for `(string)` nodes (precise: never matches
        -- braces outside strings, e.g. dict/set literals), skip f-strings via
        -- their `string_start` prefix, and extmark-highlight any `{...}` span
        -- found in the remaining strings' text.
        local ns = vim.api.nvim_create_namespace("python_template_braces")
        vim.api.nvim_set_hl(0, "PythonTemplateBrace", { fg = "#0A7FFF" })

        local function highlight_buf(bufnr)
            if vim.bo[bufnr].filetype ~= "python" then return end
            local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "python")
            if not ok or not parser then return end
            vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
            local tree = parser:parse()[1]
            if not tree then return end
            local query = vim.treesitter.query.parse("python", "(string) @str")
            for _, node in query:iter_captures(tree:root(), bufnr) do
                local start_row, start_col = node:range()
                local prefix_node = node:named_child(0)
                local is_fstring = prefix_node
                    and prefix_node:type() == "string_start"
                    and vim.treesitter.get_node_text(prefix_node, bufnr):lower():find("f")
                if not is_fstring then
                    local text = vim.treesitter.get_node_text(node, bufnr)
                    -- map a byte offset (1-indexed, within `text`) to a (row, col)
                    -- in the buffer, walking newlines from the node's start.
                    local function pos_at(offset)
                        local before = text:sub(1, offset - 1)
                        local row, last_nl = start_row, 0
                        for nl_pos in before:gmatch("()\n") do
                            row = row + 1
                            last_nl = nl_pos
                        end
                        local col = (row == start_row) and (start_col + offset - 1) or (offset - 1 - last_nl)
                        return row, col
                    end
                    local pos = 1
                    while true do
                        local s, e = text:find("{[^{}]*}", pos)
                        if not s then break end
                        local s_row, s_col = pos_at(s)
                        local e_row, e_col = pos_at(e + 1)
                        vim.api.nvim_buf_set_extmark(bufnr, ns, s_row, s_col, {
                            end_row = e_row,
                            end_col = e_col,
                            hl_group = "PythonTemplateBrace",
                        })
                        pos = e + 1
                    end
                end
            end
        end

        vim.api.nvim_create_autocmd("ColorScheme", {
            callback = function() vim.api.nvim_set_hl(0, "PythonTemplateBrace", { fg = "#0A7FFF" }) end,
        })
        vim.api.nvim_create_autocmd({ "FileType", "TextChanged", "TextChangedI", "BufEnter" }, {
            pattern = "*.py",
            callback = function(args) highlight_buf(args.buf) end,
        })
    end,
}
