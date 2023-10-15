-- below is heavily inspired by astronvim:
-- https://github.com/AstroNvim/AstroNvim/blob/fb497c6739f5d368fcba2357b02303a8c82e3ec5/lua/plugins/neo-tree.lua
-- Unless you are still migrating, remove the deprecated commands from v1.x
vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

return {
  "nvim-neo-tree/neo-tree.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
  },
  config = function ()
    require('neo-tree').setup {
      enable_git_status = true,
      enable_diagnostics = true,
      enable_normal_mode_for_inputs = true
    }
  end,
}


