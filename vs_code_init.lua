-- Config file for use in vs-code nvim extension: https://github.com/vscode-neovim/vscode-neovim
-- Separate init file because some plugins can apparently cause issues
-- There is a flag in Lazy apparently to disable plugins that cause issues when in "vscode" mode
-- But as a starting point this is simpler
vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "
require("custom.vim").apply_options()
require("custom.keybinds").setup_vim_binds()
