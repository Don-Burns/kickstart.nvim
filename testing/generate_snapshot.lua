-- Script to generate the initial diagnostics snapshot
-- Run with: nvim --headless -l testing/generate_snapshot.lua

-- Wait for startup and plugins to load
vim.wait(3000)

-- Open the test file
vim.cmd("edit " .. vim.fn.stdpath("config") .. "/testing/codesamples/test.py")
local bufnr = vim.api.nvim_get_current_buf()

-- Wait for LSP to attach
local start = vim.loop.hrtime()
local timeout = 30000000000 -- 30 seconds in nanoseconds
while true do
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    if #clients > 0 then
        print("LSP clients attached: " .. #clients)
        for _, c in ipairs(clients) do
            print("  - " .. c.name)
        end
        break
    end
    if (vim.loop.hrtime() - start) > timeout then
        print("TIMEOUT: No LSP clients attached")
        vim.cmd("qa!")
        return
    end
    vim.wait(500)
end

-- Wait for diagnostics to accumulate
print("Waiting for diagnostics...")
start = vim.loop.hrtime()
timeout = 60000000000 -- 60 seconds
while true do
    local diagnostics = vim.diagnostic.get(bufnr)
    if #diagnostics >= 3 then
        print("Got " .. #diagnostics .. " diagnostics so far...")
        break
    end
    if (vim.loop.hrtime() - start) > timeout then
        print("TIMEOUT: Not enough diagnostics. Got: " .. #vim.diagnostic.get(bufnr))
        break
    end
    vim.wait(1000)
end

-- Extra wait for slow sources (mypy, cspell)
print("Waiting for all sources to report...")
vim.wait(15000)

-- Get final diagnostics
local diagnostics = vim.diagnostic.get(bufnr)
print("Total diagnostics: " .. #diagnostics)

-- Format them
local severity_map = {
    [1] = "Error",
    [2] = "Warning",
    [3] = "Info",
    [4] = "Hint",
}
local lines = {}
for _, d in ipairs(diagnostics) do
    local line = string.format(
        "%d:%d [%s] %s (%s)",
        d.lnum + 1,
        d.col + 1,
        severity_map[d.severity] or "Unknown",
        d.message:gsub("\n", " "),
        d.source or "unknown"
    )
    table.insert(lines, line)
end
table.sort(lines)

-- Write snapshot
local snapshot_dir = vim.fn.stdpath("config") .. "/testing/snapshots"
vim.fn.mkdir(snapshot_dir, "p")
local snapshot_path = snapshot_dir .. "/test_py_diagnostics.txt"
local file = io.open(snapshot_path, "w")
if file then
    local content = table.concat(lines, "\n") .. "\n"
    file:write(content)
    file:close()
    print("Snapshot written to: " .. snapshot_path)
    print("Content:")
    print(content)
else
    print("ERROR: Failed to write snapshot file")
end

vim.cmd("qa!")
