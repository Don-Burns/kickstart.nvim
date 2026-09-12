-- Module for organising all my binds

-- State for tracking things like windows that I only want 1 copy of and if open to be reused
local state = {
    bottom_terminal = {
        buffer_id = -1,
        window_id = -1,
        last_editor_win = -1,
    },
}

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


        -- Buffer/Panel handling
        vim.keymap.set("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Vertical Split" })
        vim.keymap.set("n", "<leader>\\", "<cmd>split<cr>", { desc = "Horizontal Split" })
        vim.keymap.set("t", "<esc><esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })

        -- Track the last "real" editor window (not the bottom terminal) so we can
        -- jump back to it when toggling the terminal off.
        vim.api.nvim_create_autocmd("WinLeave", {
            callback = function()
                local win = vim.api.nvim_get_current_win()
                if win == state.bottom_terminal.window_id then
                    return
                end
                if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "" then
                    state.bottom_terminal.last_editor_win = win
                end
            end,
        })

        -- Toggle a terminal in a horizontal split below the current window. If the
        -- terminal is already open, jump to it (insert mode). If already in the
        -- terminal, jump back to the last editor window instead.
        local function toggle_terminal()
            local window = state.bottom_terminal.window_id
            local buffer = state.bottom_terminal.buffer_id

            if vim.api.nvim_get_current_win() == window then
                if vim.api.nvim_win_is_valid(state.bottom_terminal.last_editor_win) then
                    vim.api.nvim_set_current_win(state.bottom_terminal.last_editor_win)
                end
                return
            end

            if vim.api.nvim_win_is_valid(window) and vim.api.nvim_buf_is_valid(buffer) then
                vim.api.nvim_set_current_win(window)
            else
                -- if somehow the window is valid but buffer isn't
                -- e.g. I opened a terminal, then closed the buffer but not the window,
                -- but use window for something else
                if not vim.api.nvim_buf_is_valid(buffer) then
                    buffer = vim.api.nvim_create_buf(false, true)
                    state.bottom_terminal.buffer_id = buffer
                end

                window = vim.api.nvim_open_win(buffer, true, {
                    split = "below",
                    height = 15,
                    style = "minimal",
                })
                state.bottom_terminal.window_id = window
                vim.cmd.terminal()

                -- Activate venv if .venv exists in current directory
                local venv_path = vim.fn.getcwd() .. "/.venv"
                if vim.fn.isdirectory(venv_path) == 1 then
                    vim.fn.chansend(vim.b.terminal_job_id, "source .venv/bin/activate\n")
                end
            end

            vim.cmd.startinsert()
        end

        vim.keymap.set("n", "<F12>", toggle_terminal, { desc = "Toggle Terminal" })
        vim.keymap.set("t", "<F12>", function()
            vim.cmd([[stopinsert]])
            toggle_terminal()
        end, { desc = "Toggle Terminal" })

        -- Open the file under the cursor (in the last non-terminal window). Reimplemented
        -- rather than delegating to native gf/gF because those act on the *current*
        -- window's cursor, and want to read the terminal's cursor/text but open the
        -- result in a different window.
        ---@param with_line boolean Whether to parse and jump to a line/column.
        ---@param target_win integer Window that should open the file.
        ---@return nil
        local function goto_file_in_editor_win(with_line, target_win)
            local line = vim.api.nvim_get_current_line()
            local file = vim.fn.expand("<cfile>")
            if file == "" then
                return
            end
            local cfile = vim.fn.expand("<cfile>:p")

            local lnum, col
            local file_type = vim.filetype.match({ filename = cfile })
            if with_line then
                local escaped = vim.pesc(file)
                local l, c
                if file_type == "python" then
                    -- Python traceback: File "path.py", line 2
                    l, c = line:match(escaped .. [["?%s*,%s*line%s+(%d+)]])
                else
                    -- Generic tool output: path.md:2 or path.md:2:10
                    l, c = line:match(escaped .. ":(%d+):?(%d*)")
                end
                if l then
                    lnum, col = tonumber(l), tonumber(c)
                end
            end


            if vim.api.nvim_win_is_valid(target_win) then
                vim.api.nvim_set_current_win(target_win)
            end

            vim.cmd.edit(vim.fn.fnameescape(cfile))
            if lnum then
                vim.api.nvim_win_set_cursor(0, { lnum, (col or 1) - 1 })
            end
        end

        vim.api.nvim_create_autocmd("TermOpen", {
            callback = function(args)
                if args.buf ~= state.bottom_terminal.buffer_id then
                    return
                end
                vim.keymap.set("n", "gf", function()
                    goto_file_in_editor_win(false, state.bottom_terminal.last_editor_win)
                end,
                    { buffer = args.buf, desc = "[G]oto [F]ile under cursor (in editor win)" })
                vim.keymap.set("n", "gF", function()
                    goto_file_in_editor_win(true, state.bottom_terminal.last_editor_win)
                end,
                    { buffer = args.buf, desc = "[G]oto [F]ile:line under cursor (in editor win)" })
            end,
        })
    end,
    -- binds that rely on plugins so cannot be called before plugin install and other init setup
    setup_plugin_binds = function()
        -- Which key map, is what which-key uses to display what is available for next key press
        -- document existing key chains
        require("which-key").add {
            { "<leader>c",   group = "[C]ode" },
            { "<leader>c_",  hidden = true },
            { "<leader>d",   group = "[D]iagnostics" },
            { "<leader>d_",  hidden = true },
            { "<leader>f",   group = "[F]ind" },
            { "<leader>f_",  hidden = true },
            { "<leader>g",   group = "[G]it" },
            { "<leader>g_",  hidden = true },
            { "<leader>h",   group = "[H]arpoon/Git [H]unk" },
            { "<leader>h_",  hidden = true },
            { "<leader>l",   group = "[L]sp" },
            { "<leader>l_",  hidden = true },
            { "<leader>ls",  group = "[L]sp [S]symbols" },
            { "<leader>ls_", hidden = true },
            { "<leader>p",   group = "[P]roject" },
            { "<leader>p_",  hidden = true },
            { "<leader>r",   group = "[R]efactor" },
            { "<leader>r_",  hidden = true },
            { "<leader>ri",  group = "[R]efactor [I]nline" },
            { "<leader>ri_", hidden = true },
            { "<leader>s",   group = "[S]earch" },
            { "<leader>s_",  hidden = true },
            { "<leader>t",   group = "[T]oggle" },
            { "<leader>t_",  hidden = true },
        }
        -- register which-key VISUAL mode
        -- required for visual <leader>hs (hunk stage) to work
        require("which-key").add({
            { "<leader>",  group = "VISUAL <leader>", mode = "v" },
            { "<leader>h", desc = "Git [H]unk",       mode = "v" },
        })
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
        local map = function(mode, keys, func, desc)
            if desc then
                desc = "LSP: " .. desc
            end

            vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc })
        end

        local trigger_code_action = function()
            vim.lsp.buf.code_action {
                -- context = { only = { "quickfix", "refactor", "source" } } -- this line was in kickstart, but it may
                -- not be needed and causes some lsps to not show actions, e.g. null-ls with cspell
            }
        end
        -- refactors
        --- Bring up refactoring menu
        --- https://github.com/ThePrimeagen/refactoring.nvim#keymaps
        map(
            { "n", "x" },
            "<leader>rs",
            function() require("refactoring").extensions.refactoring.refactors() end,
            "[R]efactor [S]elect"
        )
        nmap("<leader>rr", vim.lsp.buf.rename, "[R]efactor [R]ename")
        map("x", "<leader>re", ":Refactor extract ", "[R]efactor [E]xtact")
        map("x", "<leader>rf", ":Refactor extract_to_file ", "[R]efactor Extact to [F]ile")
        map("x", "<leader>rv", ":Refactor extract_var ", "[R]efactor Extact [V]ariable")
        map({ "x", "n" }, "<leader>riv", ":Refactor inline_var", "[R]efactor [I]nline [V]ariable")
        nmap("<leader>rif", ":Refactor inline_func", "[R]efactor [I]nline [F]unction")
        nmap("<leader>rb", ":Refactor extract_block", "[R]efactor Extract [B]lock")
        nmap("<leader>rbf", ":Refactor extract_block_to_file", "[R]efactor Extract [B]lock to [F]ile")



        --trigger code action in normal and visual mode
        nmap("<leader>lr", vim.lsp.buf.rename, "[L]sp [R]ename")
        nmap("<leader>la", trigger_code_action, "[L]sp [A]ction")
        map("v", "<leader>la", trigger_code_action, "[L]sp [A]ction")
        nmap("<leader>lsd", require("telescope.builtin").lsp_document_symbols, "[L]SP [S]symbols [D]ocument")
        nmap("<leader>lsp", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[L]SP [S]symbols [P]roject")


        nmap("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
        nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
        nmap("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
        nmap("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

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
        nmap("<leader>tr", "<cmd>:ToggleRulers<cr>", "[T]oggle [R]ulers")
    end,
}
