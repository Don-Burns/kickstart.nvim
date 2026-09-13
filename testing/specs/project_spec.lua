local project = require("custom.project")

describe("Project config", function()
    local original_dir
    local temp_dir

    before_each(function()
        original_dir = vim.fn.getcwd()
        temp_dir = vim.fn.tempname()
        vim.fn.mkdir(temp_dir .. "/.nvim", "p")
        vim.cmd("cd " .. vim.fn.fnameescape(temp_dir))
    end)

    after_each(function()
        vim.cmd("cd " .. vim.fn.fnameescape(original_dir))
        vim.fn.delete(temp_dir, "rf")
    end)

    it("returns an empty config when the file is missing", function()
        assert.same({}, project.config())
    end)

    it("loads .nvim/config.json", function()
        vim.fn.writefile({ '{"test":{"args":["tests/unit","-k","smoke"]}}' }, temp_dir .. "/.nvim/config.json")

        assert.same({ "tests/unit", "-k", "smoke" }, project.config().test.args)
        assert.same({ "tests/unit", "-k", "smoke" }, project.get("test.args", {}))
        assert.same({ "tests/unit", "-k", "smoke" }, project.get_string_list("test.args"))
    end)

    it("falls back to VS Code pytest settings", function()
        vim.fn.mkdir(temp_dir .. "/.vscode", "p")
        vim.fn.writefile({ '{"python.testing.pytestArgs":["tests/vscode","-m","fast"]}' }, temp_dir .. "/.vscode/settings.json")

        assert.same({ "tests/vscode", "-m", "fast" }, project.get_string_list("test.args"))
    end)

    it("prefers the Neovim config over VS Code settings", function()
        vim.fn.mkdir(temp_dir .. "/.vscode", "p")
        vim.fn.writefile({ '{"python.testing.pytestArgs":["tests/vscode"]}' }, temp_dir .. "/.vscode/settings.json")
        vim.fn.writefile({ '{"test":{"args":["tests/nvim"]}}' }, temp_dir .. "/.nvim/config.json")

        assert.same({ "tests/nvim" }, project.get_string_list("test.args"))
    end)

    it("returns the default for a missing config value", function()
        assert.same({ "tests" }, project.get("test.args", { "tests" }))
    end)

    it("filters non-string values from string lists", function()
        vim.fn.writefile({ '{"test":{"args":["tests/unit",42,true]}}' }, temp_dir .. "/.nvim/config.json")

        assert.same({ "tests/unit" }, project.get_string_list("test.args"))
    end)

    it("returns an empty config for invalid JSON", function()
        local notified = false
        local notify = vim.notify
        vim.notify = function(message, level, options)
            notified = message:match("Invalid project config") ~= nil
                and level == vim.log.levels.WARN
                and options.timeout == 5000
        end
        vim.fn.writefile({ "not json" }, temp_dir .. "/.nvim/config.json")

        assert.same({}, project.config())
        assert.is_true(notified)
        vim.notify = notify
    end)
end)
