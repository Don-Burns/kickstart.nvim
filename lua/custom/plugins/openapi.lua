-- plugin based on my openapi cli tool to preview OpenAPI specs in the browser.
return {
    "Don-Burns/openapi-cli",
    ft = { "yaml", "json" },
    -- Install from Lazy's checkout only when `openapi` isn't already on PATH.
    ---@param plugin LazyPlugin
    ---@return nil
    build = function(plugin)
        if vim.fn.executable("openapi") == 1 then
            return
        end
        if vim.fn.executable("uv") ~= 1 then
            error("uv is required to install openapi-cli")
        end
        vim.fn.system({ "uv", "tool", "install", plugin.dir })
        if vim.v.shell_error ~= 0 then
            error("Failed to install openapi-cli with uv")
        end
    end,
    -- Add preview toggles to OpenAPI-capable buffers, including the buffer that loaded this plugin.
    ---@return nil
    config = function()
        -- Start or stop the preview server for the given buffer.
        ---@param buf integer
        ---@return nil
        local function toggle_preview(buf)
            local job = vim.b[buf].openapi_preview_job
            if job then
                vim.b[buf].openapi_preview_job = nil
                vim.fn.jobstop(job)
                return
            end

            local file = vim.api.nvim_buf_get_name(buf)
            if file == "" or vim.fn.filereadable(file) ~= 1 then
                vim.notify("Save the OpenAPI spec before previewing", vim.log.levels.ERROR)
                return
            end
            if vim.fn.executable("openapi") ~= 1 then
                vim.notify("openapi-cli is not installed or not on PATH", vim.log.levels.ERROR)
                return
            end

            local id
            id = vim.fn.jobstart({ "openapi", "preview", file }, {
                ---@param _job_id integer
                ---@param code integer
                ---@param _event string
                -- Clear the stored job after exit and report unexpected failures.
                on_exit = function(_job_id, code, _event)
                    local is_active = vim.api.nvim_buf_is_valid(buf) and vim.b[buf].openapi_preview_job == id
                    if is_active then
                        vim.b[buf].openapi_preview_job = nil
                        if code ~= 0 then
                            vim.notify("OpenAPI preview exited with code " .. code, vim.log.levels.ERROR)
                        end
                    end
                end,
            })
            if id <= 0 then
                vim.notify("Failed to start OpenAPI preview", vim.log.levels.ERROR)
                return
            end
            vim.b[buf].openapi_preview_job = id
        end

        ---@param buf integer
        ---@return nil
        local function setup_buffer(buf)
            -- Use the same preview-toggle key as Markdown's browser preview.
            vim.keymap.set("n", "<leader>Tp", function()
                toggle_preview(buf)
            end, { buffer = buf, desc = "OpenAPI: Toggle browser preview" })
            vim.api.nvim_create_autocmd("BufWipeout", {
                buffer = buf,
                once = true,
                ---@param _args table
                ---@return nil
                -- Stop the server when its source buffer is closed.
                callback = function(_args)
                    local job = vim.b[buf].openapi_preview_job
                    if job then
                        vim.fn.jobstop(job)
                    end
                end,
            })
        end

        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "yaml", "json" },
            ---@param args table
            ---@return nil
            -- Set up the buffer-local mapping for newly opened matching files.
            callback = function(args) setup_buffer(args.buf) end,
        })
    end,
}
