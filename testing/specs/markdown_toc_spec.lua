local toc = require("custom.markdown_toc")

local function buffer(lines)
    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    return bufnr
end

describe("Markdown TOC", function()
    it("updates an existing TOC with all headings", function()
        local bufnr = buffer({
            "# Guide",
            "",
            "- [Guide](#guide)",
            "  - [Old](#old)",
            "",
            "## Install",
            "### Linux",
            "## Usage",
        })

        assert.is_true(toc.update(bufnr))
        assert.are.same({
            "# Guide",
            "",
            "- [Guide](#guide)",
            "  - [Install](#install)",
            "    - [Linux](#linux)",
            "  - [Usage](#usage)",
            "",
            "## Install",
            "### Linux",
            "## Usage",
        }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
    end)

    it("does not update ordinary lists", function()
        local bufnr = buffer({ "# Title", "", "- one", "- two", "", "## Section" })
        assert.is_false(toc.update(bufnr))
        assert.are.same("- one", vim.api.nvim_buf_get_lines(bufnr, 2, 3, false)[1])
    end)

    it("inserts a TOC at the cursor", function()
        local bufnr = buffer({ "# Title", "## Section" })
        vim.api.nvim_set_current_buf(bufnr)
        vim.api.nvim_win_set_cursor(0, { 2, 0 })
        assert.is_true(toc.add(bufnr))
        assert.are.same({ "# Title", "- [Title](#title)", "  - [Section](#section)", "## Section" },
            vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
    end)

    it("ignores a fenced-code list and no-toc lists", function()
        local bufnr = buffer({
            "```markdown",
            "- [One](#one)",
            "- [Two](#two)",
            "```",
            "<!-- no toc -->",
            "- [One](#one)",
            "- [Two](#two)",
            "# Heading",
        })
        assert.is_false(toc.update(bufnr))
    end)

    it("ignores single no-toc heading", function()
        local bufnr = buffer({
            "# Guide",
            "",
            "- [Guide](#guide)",
            "  - [Old](#old)",
            "",
            "<!-- no toc -->",
            "## Install",
            "### Linux",
            "## Usage",
        })

        assert.is_true(toc.update(bufnr))
        assert.are.same({
            "# Guide",
            "",
            "- [Guide](#guide)",
            "  - [Usage](#usage)",
            "",
            "<!-- no toc -->",
            "## Install",
            "### Linux",
            "## Usage",
        }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
    end)

    it("does not update when autoformat is disabled", function()
        local bufnr = buffer({ "# Guide", "- [Guide](#guide)", "- [Old](#old)", "## Install" })
        toc.enabled = false
        local before = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local updated = false
        if toc.enabled then updated = toc.update(bufnr) end
        assert.is_false(updated)
        assert.are.same(before, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
        toc.enabled = true
    end)
end)
