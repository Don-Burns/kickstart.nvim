-- testing/helpers/init.lua
-- Test utilities for Neovim configuration tests

local M = {}

--- Get the path to this Neovim config directory (resolved, no symlinks)
---@return string
function M.get_config_path()
    local raw = vim.fn.stdpath("config")
    return vim.fn.resolve(raw)
end

--- Get path to testing directory
---@return string
function M.get_testing_path()
    return M.get_config_path() .. "/testing"
end

--- Get path to snapshots directory
---@return string
function M.get_snapshots_path()
    return M.get_testing_path() .. "/snapshots"
end

--- Read a snapshot file by name
---@param name string snapshot filename (e.g., "test_py_diagnostics.txt")
---@return string|nil content of the snapshot file, or nil if not found
function M.read_snapshot(name)
    local path = M.get_snapshots_path() .. "/" .. name
    local file = io.open(path, "r")
    if not file then
        return nil
    end
    local content = file:read("*a")
    file:close()
    return content
end

--- Write a snapshot file
---@param name string snapshot filename
---@param content string content to write
function M.write_snapshot(name, content)
    local dir = M.get_snapshots_path()
    vim.fn.mkdir(dir, "p")
    local path = dir .. "/" .. name
    local file = io.open(path, "w")
    if not file then
        error("Failed to open snapshot file for writing: " .. path)
    end
    file:write(content)
    file:close()
end

--- Check if we should update snapshots (via environment variable)
---@return boolean
function M.should_update_snapshots()
    return vim.env.UPDATE_SNAPSHOTS == "1"
end

--- Severity number to human-readable string
---@param severity integer vim.diagnostic.severity value
---@return string
function M.severity_to_string(severity)
    local map = {
        [vim.diagnostic.severity.ERROR] = "Error",
        [vim.diagnostic.severity.WARN] = "Warning",
        [vim.diagnostic.severity.INFO] = "Info",
        [vim.diagnostic.severity.HINT] = "Hint",
    }
    return map[severity] or "Unknown"
end

--- Format a list of diagnostics into a sorted text representation
--- Format: "{line}:{col} [{severity}] {message} ({source})"
---@param diagnostics table[] list of vim.Diagnostic objects
---@return string formatted text with one diagnostic per line
function M.format_diagnostics(diagnostics)
    local lines = {}
    for _, d in ipairs(diagnostics) do
        local line = string.format(
            "%d:%d [%s] %s (%s)",
            d.lnum + 1, -- convert 0-indexed to 1-indexed
            d.col + 1,
            M.severity_to_string(d.severity),
            d.message:gsub("\n", " "), -- flatten multiline messages
            d.source or "unknown"
        )
        table.insert(lines, line)
    end
    -- Sort by line number, then column, for stable output
    table.sort(lines)
    return table.concat(lines, "\n") .. "\n"
end

--- Wait for a condition to become true, with timeout
---@param condition function function that returns true when condition is met
---@param timeout_ms integer maximum time to wait in milliseconds
---@param poll_interval_ms integer|nil interval between checks (default 100ms)
---@return boolean true if condition was met, false if timed out
function M.wait_for(condition, timeout_ms, poll_interval_ms)
    poll_interval_ms = poll_interval_ms or 100
    local start = vim.loop.hrtime()
    local timeout_ns = timeout_ms * 1000000

    while true do
        if condition() then
            return true
        end
        if (vim.loop.hrtime() - start) > timeout_ns then
            return false
        end
        vim.wait(poll_interval_ms)
    end
end

--- Wait for LSP clients to attach to a buffer
---@param bufnr integer buffer number
---@param timeout_ms integer|nil timeout in milliseconds (default 15000)
---@return boolean true if at least one client attached
function M.wait_for_lsp(bufnr, timeout_ms)
    timeout_ms = timeout_ms or 15000
    return M.wait_for(function()
        local clients = vim.lsp.get_clients({ bufnr = bufnr })
        return #clients > 0
    end, timeout_ms)
end

--- Wait for diagnostics to be available on a buffer
---@param bufnr integer buffer number
---@param timeout_ms integer|nil timeout in milliseconds (default 30000)
---@param min_count integer|nil minimum number of diagnostics to wait for (default 1)
---@return boolean true if diagnostics appeared
function M.wait_for_diagnostics(bufnr, timeout_ms, min_count)
    timeout_ms = timeout_ms or 30000
    min_count = min_count or 1
    return M.wait_for(function()
        local diagnostics = vim.diagnostic.get(bufnr)
        return #diagnostics >= min_count
    end, timeout_ms)
end

--- Capture :messages output
---@return string
function M.capture_messages()
    local messages = vim.api.nvim_exec2("messages", { output = true })
    return messages.output or ""
end

--- Compare content against a snapshot, updating if UPDATE_SNAPSHOTS=1
--- Returns true if match (or updated), false with diff info if mismatch
---@param name string snapshot filename
---@param actual string actual content to compare
---@return boolean match whether the snapshot matches
---@return string|nil diff description of differences if mismatch
function M.assert_snapshot(name, actual)
    if M.should_update_snapshots() then
        M.write_snapshot(name, actual)
        return true, nil
    end

    local expected = M.read_snapshot(name)
    if expected == nil then
        -- No snapshot exists yet - create it
        M.write_snapshot(name, actual)
        return true, nil
    end

    if actual == expected then
        return true, nil
    end

    -- Build a useful diff message
    local expected_lines = vim.split(expected, "\n")
    local actual_lines = vim.split(actual, "\n")
    local diff_msg = string.format(
        "Snapshot mismatch for '%s':\n  Expected %d lines, got %d lines.\n"
            .. "  Run with UPDATE_SNAPSHOTS=1 to update.\n\n"
            .. "  Expected:\n%s\n\n  Actual:\n%s",
        name,
        #expected_lines,
        #actual_lines,
        expected,
        actual
    )
    return false, diff_msg
end

return M
