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
  opts = function()
    return {
    window = {
      commands = {
          parent_or_close = function(state)
            local node = state.tree:get_node()
            if (node.type == "directory" or node:has_children()) and node:is_expanded() then
              state.commands.toggle_node(state)
            else
              require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
            end
          end,
          child_or_open = function(state)
            local node = state.tree:get_node()
            if node.type == "directory" or node:has_children() then
              if not node:is_expanded() then -- if unexpanded, expand
                state.commands.toggle_node(state)
              else -- if expanded and has children, seleect the next child
                require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
              end
            else -- if not a directory just open it
              state.commands.open(state)
            end
          end
        },
      mappings = {
        ['h'] = "parent_or_close",
        ['l'] = "child_or_open",
        ['o'] = "open",
      }
    }
  }
  end
}


