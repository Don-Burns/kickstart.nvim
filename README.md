# kickstart.nvim

This config was originally based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) and has since be heavily customized to my use.
The [old README](./README_OLD.md) is still in this repo for later referencing as there is still good info there that I don't want to have in the main README

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
