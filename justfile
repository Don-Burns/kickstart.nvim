install-config-dependencies:
    cargo install --locked tree-sitter-cli
    npm install -g cspell@@10.0.0
    uv tool install mypy ruff black

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
