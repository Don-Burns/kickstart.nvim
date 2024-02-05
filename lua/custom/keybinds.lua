-- Module for organising all my binds
return {
    -- for keymaps which are vim only.
    -- split from plugin related ones so these can load first and give me max functionality if I break the config =P
    setup_vim_binds = function()
        -- [[ Basic Keymaps ]]

        -- Keymaps for better default experience
        -- See `:help vim.keymap.set()`
        vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

        -- Remap for dealing with word wrap
        vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
        vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

        -- Diagnostic keymaps
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
        vim.keymap.set("n", "<leader>dd", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

        -- File save
        vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
    end,
    -- binds that rely on plugins so cannot be called before plugin install and other init setup
    setup_plugin_binds = function()
        -- Which key map, is what which-key uses to display what is available for next key press
        -- document existing key chains
        require("which-key").register {
            ["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
            ["<leader>d"] = { name = "[D]iagnostics", _ = "which_key_ignore" },
            ["<leader>g"] = { name = "[G]it", _ = "which_key_ignore" },
            ["<leader>h"] = { name = "[H]arpoon/Git [H]unk", _ = "which_key_ignore" },
            ["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
            ["<leader>s"] = { name = "[S]earch", _ = "which_key_ignore" },
            ["<leader>t"] = { name = "[T]oggle", _ = "which_key_ignore" },
            ["<leader>f"] = { name = "[F]ind", _ = "which_key_ignore" },
            ["<leader>l"] = { name = "[L]sp", _ = "which_key_ignore" },
            ["<leader>ls"] = { name = "[L]sp [S]symbols", _ = "which_key_ignore" },
            ["<leader>p"] = { name = "[P]roject", _ = "which_key_ignore" },
        }
        -- register which-key VISUAL mode
        -- required for visual <leader>hs (hunk stage) to work
        require("which-key").register({
            ["<leader>"] = { name = "VISUAL <leader>" },
            ["<leader>h"] = { "Git [H]unk" },
        }, { mode = "v" })
        -- commenting
        require("Comment").setup({
            ---Add a space b/w comment and the line
            padding = true,
            ---Whether the cursor should stay at its position
            sticky = true,
            ---Lines to be ignored while (un)comment
            ignore = nil,
            ---LHS of toggle mappings in NORMAL mode
            toggler = {
                ---Line-comment toggle keymap
                line = "gcc",
                ---Block-comment toggle keymap
                block = "gbc",
            },
            ---LHS of operator-pending mappings in NORMAL and VISUAL mode
            opleader = {
                ---Line-comment keymap
                line = "gc",
                ---Block-comment keymap
                block = "gb",
            },
            ---LHS of extra mappings
            extra = {
                ---Add comment on the line above
                above = "gcO",
                ---Add comment on the line below
                below = "gco",
                ---Add comment at the end of line
                eol = "gcA",
            },
            ---Enable keybindings
            ---NOTE: If given `false` then the plugin won't create any mappings
            mappings = {
                ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
                basic = true,
                ---Extra mapping; `gco`, `gcO`, `gcA`
                extra = true,
            },
            ---Function to call before (un)comment
            pre_hook = nil,
            ---Function to call after (un)comment
            post_hook = nil,
        })
        local comment_line = function() require("Comment.api").toggle.linewise.count(vim.v.count > 0 and vim.v.count or 1) end
        vim.keymap.set("n", "<leader>/", comment_line, { desc = "Toggle comment line" })
        -- vim.keymap.set('n', '<C-/>', comment_line, { desc = 'Toggle comment line' })
        vim.keymap.set("n", "<leader>q", "<cmd>confirm q<cr>", { desc = "Quit (:q)" })
        vim.keymap.set("n", "<C-s>", "<cmd>w!<cr>", { desc = "Force write (:w!)" })
        vim.keymap.set("n", "<C-q>", "<cmd>wqa!<cr>", { desc = "Force save and quit (:wq!)" })
        vim.keymap.set("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Vertical Split" })
        vim.keymap.set("n", "<leader>\\", "<cmd>split<cr>", { desc = "Horizontal Split" })

        -- Todo keymaps
        vim.keymap.set("n", "<leader>pt", "<cmd>TodoTelescope<cr>", { desc = "[P]roject [T]odo List" })

        -- Harpoon keymaps
        local harpoon = require("harpoon")
        vim.keymap.set("n", "<leader>ha", function() harpoon:list():append() end, { desc = "[H]arpoon [A]dd" })
        vim.keymap.set("n", "<leader>hl", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
            { desc = "[H]arpoon [L]ist" })
        vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon Item 1" })
        vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon Item 2" })
        vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon Item 3" })
        vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon Item 4" })
        -- Toggle previous & next buffers stored within Harpoon list
        vim.keymap.set("n", "<C-p>", function() harpoon:list():prev() end, { desc = "Harpoon Previous" })
        vim.keymap.set("n", "<C-n>", function() harpoon:list():next() end, { desc = "Harpoon Next" })
    end,
    -- on attach function that can be passed to lsps so binds are set when LSP attaches to buffer
    lsp_on_attach_binds = function(_, bufnr)
        -- NOTE: Remember that lua is a real programming language, and as such it is possible
        -- to define small helper and utility functions so you don't have to repeat yourself
        -- many times.
        --
        -- In this case, we create a function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.
        local nmap = function(keys, func, desc)
            if desc then
                desc = "LSP: " .. desc
            end

            vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
        end

        nmap("<leader>lr", vim.lsp.buf.rename, "[L]sp [R]ename")
        nmap("<leader>la", function()
            vim.lsp.buf.code_action { context = { only = { "quickfix", "refactor", "source" } } }
        end, "[L]sp [A]ction")

        nmap("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
        nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
        nmap("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
        nmap("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
        nmap("<leader>lsd", require("telescope.builtin").lsp_document_symbols, "[L]SP [S]symbols [D]ocument")
        nmap("<leader>lsp", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[L]SP [S]symbols [P]roject")

        -- See `:help K` for why this keymap
        nmap("K", vim.lsp.buf.hover, "Hover Documentation")
        nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

        -- Lesser used LSP functionality
        nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
        nmap("<leader>pa", vim.lsp.buf.add_workspace_folder, "[P]roject [A]dd Folder")
        nmap("<leader>pr", vim.lsp.buf.remove_workspace_folder, "[P]roject [R]emove Folder")
        nmap("<leader>pl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, "[P]roject [L]ist Folders")

        -- Formatting Keybinds
        -- Create a command `:Format` local to the LSP buffer
        vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
            vim.lsp.buf.format()
        end, { desc = "Format current buffer with LSP" })
        nmap("<leader>lf", "<cmd>:Format<cr>", "[F]ormat Current Buffer")
        nmap("<leader>tf", "<cmd>:ToggleAutoFormat<cr>", "[T]oggle Auto [F]ormat")
    end,
}
