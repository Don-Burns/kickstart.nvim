-- Options for the status line with mode, git status etc at bottom of buffer

-- Function to get the active python version including venv if active
local function get_py_env()
    -- if active file is not python file don't display TODO:

    is_venv = function()
        if os.getenv("VIRTUAL_ENV") ~= nil or os.getenv("CONDA_DEFAULT_ENV") ~= nil
        then
            return true
        end
        return false
    end

    local err_str = "???"

    -- e.g. Python 3.10.1
    local err, py_cli = pcall(
        function()
            local handle = io.popen("python3 --version")
            local output = handle:read("*l")
            if output == nil
            then
                return err_str
            end

            return output
        end
    )
    if not err then
        return err_str
    end

    -- trim the leading `python from string`
    local err, py_ver = pcall(string.gsub, py_cli, "^Python ", "")
    if not err then
        return err_str
    end

    -- add venv prefix if in venv
    if is_venv()
    then
        py_ver = "(venv) " .. py_ver
    end

    return "" .. py_ver
end


return {
    -- Set lualine as statusline
    "nvim-lualine/lualine.nvim",
    -- See `:help lualine.txt`
    opts = {
        options = {
            icons_enabled = true,
            theme = "auto",
            component_separators = { left = "", right = "" },
            section_separators = { left = "", right = "" },
            disabled_filetypes = {
                statusline = {},
                winbar = {},
            },
            ignore_focus = {},
            always_divide_middle = true,
            globalstatus = false,
            refresh = {
                statusline = 1000,
                tabline = 1000,
                winbar = 1000,
            }
        },
        sections = {
            lualine_a = { "mode" },
            lualine_b = { "branch", "diff", "diagnostics" },
            lualine_c = { "filename" },
            lualine_x = { "encoding", "fileformat", "filetype", get_py_env },
            lualine_y = { "location", "progress" },
            lualine_z = { "location" }
        },
        inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = { "filename" },
            lualine_x = { "location" },
            lualine_y = {},
            lualine_z = {}
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {}


    }
}
