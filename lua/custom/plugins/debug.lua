-- for debuggers

return {
    "mfussenegger/nvim-dap",
    dependencies = {
        -- Creates a beautiful debugger UI
        "rcarriga/nvim-dap-ui",

        -- Installs the debug adapters for you
        "williamboman/mason.nvim",
        "jay-babu/mason-nvim-dap.nvim",

        -- Add language debuggers here
        -- (For running tests with debugger, see below)
        "leoluz/nvim-dap-go",
        "mfussenegger/nvim-dap-python",

        -- for running tests with debugger
        ---- Base
        "nvim-neotest/nvim-nio",
        "nvim-neotest/neotest",
        "antoinemadec/FixCursorHold.nvim",
        ---- Language specific adapters
        {
            "nvim-neotest/neotest-python",
            -- bug in the latest commit (2026-09-13 -> think is due to `51c453d57f8d5156671b42ea57fafa2e1c9fb641`)
            commit = "cc62d70ae4d3f238ed04dac643d6ddcdad27d9ad",
        },
    },
    config = function()
        local dap = require "dap"
        local dapui = require "dapui"

        require("mason-nvim-dap").setup {
            -- Makes a best effort to setup the various debuggers with
            -- reasonable debug configurations
            automatic_setup = true,

            -- You can provide additional configuration to the handlers,
            -- see mason-nvim-dap README for more information
            handlers = {},

            -- You'll need to check that you have the required things installed
            -- online, please don't ask me how to install them :)
            ensure_installed = {
                -- Update this to ensure that you have the debuggers for the langs you want
                "delve",
                "debugpy",
            },
        }

        -- Basic debugging keymaps, feel free to change to your liking!
        vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
        vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
        vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
        vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
        vim.keymap.set("n", "<F7>", dap.close, { desc = "Debug: Stop" })
        vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
        vim.keymap.set("n", "<leader>B", function()
            dap.set_breakpoint(vim.fn.input "Breakpoint condition: ")
        end, { desc = "Debug: Set Breakpoint" })

        -- Testing keymaps
        local neotest = require "neotest"
        neotest.setup {
            adapters = {
                require("neotest-python") {
                    args = { "-vv" },
                    dap = {
                        -- Workaround for debugpy's Python 3.12+ sys.monitoring bug:
                        -- https://github.com/microsoft/debugpy/issues/1970
                        env = { PYDEVD_USE_SYS_MONITORING = "0" },
                    },
                },
            },
        }

        vim.keymap.set("n", "<leader>tt", function()
            neotest.run.run({ strategy = "dap" })
            -- don't need to check if open. already checks in open function
            neotest.summary.open()
        end, { desc = "Test: Run nearest test" })
        vim.keymap.set("n", "<leader>tf", function()
            neotest.run.run(vim.fn.expand "%")
            -- don't need to check if open. already checks in open function
            neotest.summary.open()
        end, { desc = "Test: Run current file" })
        vim.keymap.set("n", "<leader>tp", function()
            local project = require "custom.project"
            local root = project.root()
            local options = project.get_string_list("test.args")

            if #options > 0 then
                neotest.run.run({ root, extra_args = options })
            else
                neotest.run.run(root)
            end
            neotest.summary.open()
        end, { desc = "Test: Run project" })
        vim.keymap.set("n", "<leader>tl", function()
            neotest.run.run_last()
            neotest.summary.open()
        end, { desc = "Test: Run last" })
        vim.keymap.set("n", "<leader>tm", function()
            neotest.summary.run_marked()
            neotest.summary.open()
        end, { desc = "Test: Run marked" })
        -- Also map F23/F24 for convenience on my keyboard 2nd layer
        vim.keymap.set("n", "<F24>", function()
            neotest.run.run({ strategy = "dap" })
            -- don't need to check if open. already checks in open function
            neotest.summary.open()
        end, { desc = "Test: Run nearest test" })
        vim.keymap.set("n", "<F23>", function()
            neotest.run.run(vim.fn.expand "%")
            -- don't need to check if open. already checks in open function
            neotest.summary.open()
        end, { desc = "Test: Run current file" })
        vim.keymap.set("n", "<leader>ts", function()
            neotest.summary.toggle()
        end, { desc = "Test: Toggle summary" })
        vim.keymap.set("n", "<leader>tw", function()
            neotest.watch.watch(vim.fn.expand "%")
        end, { desc = "Test: Watch" })

        -- Dap UI setup
        -- For more information, see |:help nvim-dap-ui|
        dapui.setup {
            -- Set icons to characters that are more likely to work in every terminal.
            --    Feel free to remove or use ones that you like more! :)
            --    Don't feel like these are good choices.
            icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
            controls = {
                icons = {
                    pause = "⏸",
                    play = "▶",
                    step_into = "⏎",
                    step_over = "⏭",
                    step_out = "⏮",
                    step_back = "b",
                    run_last = "▶▶",
                    terminate = "⏹",
                    disconnect = "⏏",
                },
            },
        }

        -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
        vim.keymap.set("n", "<F7>", dapui.toggle, { desc = "Debug: See last session result." })

        dap.listeners.after.event_initialized["dapui_config"] = dapui.open
        dap.listeners.before.event_terminated["dapui_config"] = dapui.close
        dap.listeners.before.event_exited["dapui_config"] = dapui.close

        -- Install golang specific config
        require("dap-go").setup()
        -- Python config
        -- pass uv so debugpy is injected into the run command.
        -- This is needed for neotest to work with dap.
        require("dap-python").setup("uv")
    end,
}
