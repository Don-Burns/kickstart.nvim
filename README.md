# kickstart.nvim

This config was originally based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) and has since be heavily customized to my use.
The [old README](./README_OLD.md) is still in this repo for later referencing as there is still good info there that I don't want to have in the main README

## Installation

If you have an existing nvim config, you may want to back it up first.
```sh
mv "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
```

Clone kickstart.nvim:

- on Linux and Mac
```sh
git clone https://github.com/Don-Burns/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
```

- on Windows (cmd)
```cmd
git clone https://github.com/Don-Burns/kickstart.nvim.git %userprofile%\AppData\Local\nvim\ 
```

- on Windows (powershell)
```powershell
git clone https://github.com/Don-Burns/kickstart.nvim.git $env:USERPROFILE\AppData\Local\nvim\ 
```


### Trouble Shooting
Most requirements are automatically installed by the config. However, there are a few things that may need to be installed manually.
These are:
* Make sure to review the readmes of the plugins if you are experiencing errors. In particular:
  * [ripgrep](https://github.com/BurntSushi/ripgrep#installation) is required for multiple [telescope](https://github.com/nvim-telescope/telescope.nvim#suggested-dependencies) pickers.
* See [Windows Installation](#Windows-Installation) if you have trouble with `telescope-fzf-native`

## Configuring

Top level configuration is handled in [init.lua](./init.lua). In general changes won't needed here much unless there is some ordering needed to imports.
There are still config configs I have not migrated out of there yet too, e.g. mason, telescope.

All new config should be added to the [custom](./lua/custom/) dir.
Non-plugin related config can go at that level.
Plugin configs should go to [plugins](./lua/custom/plugins/) dir.

### Plugin Config

In general the installation using Lazy (The plugin manager in use) will be on the repos for the plugin.
Occasionally a plugin will need config/setup to be called. This can be done in a "config" function.
e.g.
```lua
return {
  '{Author/PackageName.nvim}',
  config = function()
    -- custom logic goes here
  end,
}
```
