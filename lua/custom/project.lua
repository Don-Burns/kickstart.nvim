-- For configuring project by project options

---@class ProjectConfig
---@field test? ProjectTestConfig
--- Example: `{ "test": { "args": ["tests/unit", "-k", "smoke"] } }`
---@class ProjectTestConfig
---@field args? string[] Arguments passed to the test runner.

local M = {}
local loaded_root
---@type ProjectConfig|nil
local loaded_config

--- Return the current project root.
---@return string
function M.root()
    return vim.fn.getcwd()
end

--- Load `.nvim/config.json` for the current project.
--- Invalid JSON produces a warning notification and an empty config.
---@return ProjectConfig
function M.config()
    local root = M.root()
    if loaded_root == root then
        return loaded_config
    end

    loaded_root = root
    local path = root .. "/.nvim/config.json"
    if vim.fn.filereadable(path) ~= 1 then
        loaded_config = {}
        return loaded_config
    end

    local ok, config = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), "\n"))
    if not ok or type(config) ~= "table" then
        vim.notify("Invalid project config: " .. path, vim.log.levels.WARN, { timeout = 5000 })
        loaded_config = {}
        return loaded_config
    end

    loaded_config = config
    return loaded_config
end

--- Read a nested project config value using a dotted path.
---@generic T
---@param path string e.g. `"test.args"`
---@param default T value returned when the path does not exist
---@return T
function M.get(path, default)
    local value = M.config()
    for key in path:gmatch "[^.]+" do
        if type(value) ~= "table" then
            return default
        end
        value = value[key]
    end
    return value == nil and default or value
end

--- Read a string-list config value, discarding values of other types.
---@param path string e.g. `"test.args"`
---@return string[]
function M.get_string_list(path)
    local values = M.get(path, {})
    if type(values) ~= "table" then
        return {}
    end
    return vim.tbl_filter(function(value)
        return type(value) == "string"
    end, values)
end

return M
