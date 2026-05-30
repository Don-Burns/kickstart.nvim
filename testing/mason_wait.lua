-- testing/mason_wait.lua
-- Headless script that installs all Mason packages required by the config
-- and polls until they are all installed (or times out with a non-zero exit).
--
-- Usage (from CI):
--   nvim --headless +"luafile testing/mason_wait.lua"

local TIMEOUT_MS = 180000 -- 3 minutes
local POLL_INTERVAL_MS = 1000

-- Bootstrap: source the full config so Mason/mason-lspconfig are loaded
local config_path = vim.fn.stdpath("config")
vim.cmd("source " .. config_path .. "/init.lua")

local registry = require("mason-registry")
local mason_lspconfig = require("mason-lspconfig")

-- Collect the Mason package names that mason-lspconfig would install.
-- mason-lspconfig maps lspconfig names (e.g. "lua_ls") to Mason package names
-- (e.g. "lua-language-server") via get_mappings().
local mappings = mason_lspconfig.get_mappings()
local lspconfig_to_mason = mappings.lspconfig_to_mason or {}

-- The servers table keys from init.lua (loaded via ensure_installed)
local ensure_installed = mason_lspconfig.get_installed_servers and {} or {}

-- Derive packages from the ensure_installed option by reading the config directly.
-- Re-read the servers table from init.lua's mason-lspconfig setup.
local packages_to_install = {}
local seen = {}

-- Get packages from mason-lspconfig ensure_installed list
for lspconfig_name, mason_name in pairs(lspconfig_to_mason) do
    -- We only care about servers that are actually in our config.
    -- Check if this server has a mapping and is configured.
    if mason_name then
        seen[mason_name] = true
    end
end

-- More reliable: get the list of servers mason-lspconfig knows about from our config
-- by checking what's actually configured in the servers table.
-- We re-derive from the source of truth: the servers table in init.lua.
local servers = {
    "gopls",
    "zuban",
    "ruff",
    "rust_analyzer",
    "dockerls",
    "html",
    "lua_ls",
    "sqlls",
    "yamlls",
    "jsonls",
    "cspell_ls",
}

-- Map lspconfig server names to Mason package names
for _, server_name in ipairs(servers) do
    local mason_name = lspconfig_to_mason[server_name]
    if mason_name then
        table.insert(packages_to_install, mason_name)
    else
        -- Some servers share their lspconfig name with the mason name
        -- or may not be in the mapping (e.g. custom/third-party servers).
        -- Skip these with a warning rather than failing.
        print("WARNING: No Mason mapping for lspconfig server '" .. server_name .. "', skipping")
    end
end

-- Additional non-LSP tools that tests need (linters/formatters via null-ls/none-ls)
local extra_tools = { "mypy" }
for _, tool in ipairs(extra_tools) do
    table.insert(packages_to_install, tool)
end

print("Mason packages to install: " .. table.concat(packages_to_install, ", "))

-- Refresh the registry to get latest package info
registry.refresh()

-- Kick off installation for any packages not yet installed
for _, pkg_name in ipairs(packages_to_install) do
    local ok, pkg = pcall(registry.get_package, pkg_name)
    if not ok then
        print("ERROR: Package '" .. pkg_name .. "' not found in Mason registry")
        vim.cmd("cq1")
        return
    end
    if not pkg:is_installed() then
        print("Installing: " .. pkg_name)
        pkg:install()
    else
        print("Already installed: " .. pkg_name)
    end
end

-- Poll until all packages are installed or timeout
local elapsed = 0

local function all_installed()
    for _, pkg_name in ipairs(packages_to_install) do
        local ok, pkg = pcall(registry.get_package, pkg_name)
        if not ok or not pkg:is_installed() then
            return false
        end
    end
    return true
end

local function any_failed()
    for _, pkg_name in ipairs(packages_to_install) do
        local ok, pkg = pcall(registry.get_package, pkg_name)
        if ok then
            local handle = pkg:get_handle()
            if handle and handle:is_closed() and not pkg:is_installed() then
                return pkg_name
            end
        end
    end
    return nil
end

while not all_installed() do
    vim.wait(POLL_INTERVAL_MS)
    elapsed = elapsed + POLL_INTERVAL_MS

    local failed = any_failed()
    if failed then
        print("ERROR: Package '" .. failed .. "' failed to install")
        vim.cmd("cq1")
        return
    end

    if elapsed >= TIMEOUT_MS then
        -- Report which packages didn't finish
        local pending = {}
        for _, pkg_name in ipairs(packages_to_install) do
            local ok, pkg = pcall(registry.get_package, pkg_name)
            if not ok or not pkg:is_installed() then
                table.insert(pending, pkg_name)
            end
        end
        print("ERROR: Mason install timed out after " .. (TIMEOUT_MS / 1000) .. "s")
        print("Still pending: " .. table.concat(pending, ", "))
        vim.cmd("cq1")
        return
    end

    -- Progress indicator every 10 seconds
    if elapsed % 10000 == 0 then
        local installed_count = 0
        for _, pkg_name in ipairs(packages_to_install) do
            local ok, pkg = pcall(registry.get_package, pkg_name)
            if ok and pkg:is_installed() then
                installed_count = installed_count + 1
            end
        end
        print(string.format("[%ds] %d/%d packages installed...", elapsed / 1000, installed_count, #packages_to_install))
    end
end

print("All " .. #packages_to_install .. " Mason packages installed successfully")
vim.cmd("qa!")
