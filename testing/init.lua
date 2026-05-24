-- testing/init.lua
-- Test initialization file used by PlenaryBusted subprocesses.
-- Loads the full Neovim config and adds testing utilities to the Lua path.

local config_path = vim.fn.stdpath("config")

-- Add config root to Lua package path so specs can require("testing.helpers")
package.path = config_path .. "/?.lua;"
    .. config_path .. "/?/init.lua;"
    .. package.path

-- Source the full Neovim configuration
vim.cmd("source " .. config_path .. "/init.lua")
