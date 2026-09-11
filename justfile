install-config-dependencies:
    @command -v tree-sitter >/dev/null 2>&1 && echo "tree-sitter-cli already installed, skipping" || cargo install --locked tree-sitter-cli@0.27.0
    npm install -g cspell@10.0.0
    @command -v mypy >/dev/null 2>&1 && echo "mypy already installed, skipping" || uv tool install mypy==2.3.1
    @command -v ruff >/dev/null 2>&1 && echo "ruff already installed, skipping" || uv tool install ruff==0.16.7
    @command -v black >/dev/null 2>&1 && echo "black already installed, skipping" || uv tool install black==26.5.1

# Run all tests
test:
    nvim --headless +"PlenaryBustedDirectory testing/specs/ {init = vim.fn.stdpath('config') .. '/testing/init.lua'}"

# Update snapshot baselines (run when diagnostics legitimately change)
update-snapshots:
    UPDATE_SNAPSHOTS=1 nvim --headless +"PlenaryBustedDirectory testing/specs/ {init = vim.fn.stdpath('config') .. '/testing/init.lua'}"

# Run a specific test file
test-file FILE:
    nvim --headless +"lua require('plenary.test_harness').test_directory('{{FILE}}', {init = vim.fn.stdpath('config') .. '/testing/init.lua'})"

# Generate/regenerate the diagnostics snapshot only
generate-snapshot:
    nvim --headless +"luafile testing/generate_snapshot.lua"
