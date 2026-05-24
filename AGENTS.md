# AGENTS.md

## Structure

- `init.lua` - entry point; bootstraps lazy.nvim, core plugins, telescope, treesitter, LSP
- `lua/custom/vim.lua` - core vim options (leader is `<Space>`)
- `lua/custom/keybinds.lua` - all keymaps; vim-only binds load first, plugin binds after lazy.setup
- `lua/custom/plugins/*.lua` - plugin configs; each file returns a lazy.nvim spec
- `testing/` - automated test suite (see Testing section below)

## Adding Plugins

Add new plugin configs to `lua/custom/plugins/`. Use lazy.nvim spec format:

```lua
return {
  "author/plugin.nvim",
  config = function()
    -- setup here
  end,
}
```

## Code Style

Lua style enforced via `.editorconfig`:
- 4-space indent, double quotes, 120 char max line, LF endings

## LSP

- Mason auto-installs LSP servers defined in `init.lua` `servers` table
- Auto-format on save via LSP (`:ToggleAutoFormat` to disable)
- none-ls handles mypy, cspell, yamlfix

## Key Patterns

- Keybinds split: `setup_vim_binds()` runs before plugins, `setup_plugin_binds()` after
- LSP keybinds attached via `lsp_on_attach_binds` passed to each server

## Testing

Tests use plenary.nvim's test harness with the full config loaded. Run via `just test`.

### Structure
- `testing/specs/*.lua` - test specifications (plenary busted format)
- `testing/snapshots/` - expected output for snapshot tests (text-based)
- `testing/helpers/init.lua` - test utilities (snapshot I/O, wait helpers, formatting)
- `testing/codesamples/` - sample files used by tests
- `testing/generate_snapshot.lua` - script to regenerate diagnostics snapshot

### Running Tests
```sh
just test                                       # Run all tests
just test-file testing/specs/startup_spec.lua   # Run a specific test file
just update-snapshots                           # Regenerate snapshot baselines
just generate-snapshot                          # Regenerate diagnostics snapshot only
```

### Adding Tests
Create `testing/specs/{name}_spec.lua` using plenary busted format:
```lua
local helpers = require("testing.helpers")

describe("Feature", function()
    it("does something", function()
        assert.is_true(true)
    end)
end)
```

### Snapshot Testing
Diagnostics snapshot tests compare current LSP/linter output against a baseline file.
When diagnostics legitimately change (tool version updates, config changes):
1. Run `just update-snapshots`
2. Review changes with `git diff testing/snapshots/`
3. Commit the updated snapshot files

### CI
Tests run in GitHub Actions on push/PR (`.github/workflows/test.yml`).
CI installs Neovim 0.12.2, bootstraps plugins via Lazy, installs LSP servers via Mason.
