-- Goal is to automatically update markdown TOC on save.
-- This mimic the "All in One" vs code extension's TOC update behavior
-- That would have a commond to add a TOC and would update according to the headings in the file on save.
-- Rather than relying on comments to mark the TOC,
-- this determines the TOC by looking for a list of links to headings at the top of the file,
-- and will update that list on save.
--
-- There is some consideration taken for larger files, so it will only scan the first 200 lines of the file for a TOC,
-- and will not include a heading if there is a comment <!-- no toc --> above it

local M = {}
M.enabled = true
M.max_scan_lines = 200 -- how far to look for an existing TOC before giving up

-- Mirrors the :ToggleAutoFormat state (see lua/custom/plugins/formatting.lua)
-- via the User autocmd it broadcasts, instead of that module requiring us directly.
vim.api.nvim_create_autocmd("User", {
    pattern = "AutoFormatToggled",
    callback = function(args)
        M.enabled = args.data.enabled
    end,
})

local function is_fence(line)
    -- A ``` or ~~~ code-fence delimiter (optionally indented); toggles
    -- whether we're inside a fenced code block so its contents are ignored.
    return line:match("^%s*```") or line:match("^%s*~~~")
end

local function slugify(text, used)
    -- Github-style anchor slug: lowercase, strip inline HTML tags and markdown
    -- emphasis markers, drop anything that isn't a word char/space/hyphen,
    -- then collapse whitespace runs into single hyphens and trim leading/
    -- trailing hyphens.
    local slug = text:lower():gsub("<[^>]+>", ""):gsub("[`*_~]", "")
    slug = slug:gsub("[^%w%s%-]", ""):gsub("%s+", "-"):gsub("%-+", "-"):gsub("^%-", ""):gsub("%-$", "")
    -- Github disambiguates repeated headings/slugs by appending -1, -2, ...
    local base = slug
    local count = used[base] or 0
    used[base] = count + 1
    return count == 0 and slug or slug .. "-" .. count
end

local function headings(lines)
    local result, used, fenced = {}, {}, false
    -- <!-- no toc --> excludes the next heading and its descendants (deeper
    -- levels) from the generated TOC, until a heading at the same or a
    -- shallower level appears.
    local skip_next, skip_level = false, nil
    local function record(level, title)
        if skip_level and level > skip_level then
            return
        end
        skip_level = nil
        if skip_next then
            skip_next, skip_level = false, level
            return
        end
        result[#result + 1] = { level = level, title = title, slug = slugify(title, used) }
    end
    local i = 1
    while i <= #lines do
        local line = lines[i]
        if is_fence(line) then
            fenced = not fenced
        elseif not fenced then
            if line == "<!-- no toc -->" then
                skip_next = true
            else
                -- ATX heading: leading #'s, then title, with any trailing
                -- "closing" #'s (e.g. "## Title ##") stripped off.
                local hashes, title = line:match("^%s*(#+)%s+(.+)%s*$")
                if hashes then
                    title = title:gsub("%s+#+%s*$", "")
                    record(#hashes, title)
                elseif line:match("^ {0,3}[^#%s].*$") and i < #lines then
                    -- Setext heading: a text line followed by a line of all
                    -- "=" (level 1) or all "-" (level 2). Up to 3 leading
                    -- spaces allowed per CommonMark; must not start with # or
                    -- whitespace (that's an ATX heading or blank line).
                    local underline = lines[i + 1]
                    local level = underline:match("^%s*(=+)%s*$") and 1 or underline:match("^%s*(-+)%s*$") and 2
                    if level then
                        local title = line:gsub("%s+$", "")
                        record(level, title)
                        i = i + 1
                    end
                end
            end
        end
        i = i + 1
    end
    return result
end

local function toc_item(line)
    -- Matches a single TOC list entry: "<indent><marker> [title](#link)".
    -- Tried as an unordered item ("-"/"+"/"*") first, then as an ordered
    -- item ("1." or "1)"), since only one marker style applies per line.
    local indent, marker, title, link = line:match("^(%s*)([-+*])%s+%[([^]]+)%]%((#.-)%)%s*$")
    if not indent then
        indent, marker, title, link = line:match("^(%s*)(%d+)[.)]%s+%[([^]]+)%]%((#.-)%)%s*$")
    end
    return indent, marker, title, link
end

local function find_toc(lines)
    local fenced, candidate, blocked = false, nil, false
    for i = 1, math.min(#lines, M.max_scan_lines) do
        local line = lines[i]
        if is_fence(line) then
            fenced = not fenced
        elseif not fenced then
            if line == "<!-- no toc -->" then
                if candidate and candidate.count >= 2 then return candidate end
                candidate = nil
                blocked = true
            else
                local indent, marker = toc_item(line)
                if indent and not blocked and (not candidate and #indent == 0 or candidate) then
                    if not candidate then
                        candidate = {
                            first = i,
                            last = i,
                            count = 1,
                            marker = marker,
                            ordered = marker:match("%d") ~=
                                nil
                        }
                    else
                        candidate.last, candidate.count = i, candidate.count + 1
                    end
                elseif candidate and line:match("^%s*$") then
                    -- Keep the separator outside the replaceable list.
                elseif candidate then
                    if candidate.count >= 2 then return candidate end
                    candidate = nil
                elseif not line:match("^%s*$") then
                    blocked = false
                end
            end
        end
    end
    return candidate and candidate.count >= 2 and candidate or nil
end

local function generate(lines, marker, ordered)
    local hs = headings(lines)
    if not hs or #hs == 0 then return {} end
    local start = hs[1].level
    local result = {}
    for _, heading in ipairs(hs) do
        local indent = string.rep("  ", math.max(0, heading.level - start))
        local item_marker = ordered and "1." or marker
        result[#result + 1] = indent .. item_marker .. " [" .. heading.title .. "](#" .. heading.slug .. ")"
    end
    return result
end

function M.update(bufnr)
    bufnr = bufnr or 0
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local toc = find_toc(lines)
    if not toc then return false end
    local replacement = generate(lines, toc.marker, toc.ordered)
    if #replacement == 0 then return false end
    vim.api.nvim_buf_set_lines(bufnr, toc.first - 1, toc.last, false, replacement)
    return true
end

function M.add(bufnr)
    bufnr = bufnr or 0
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local replacement = generate(lines, "-", false)
    if #replacement == 0 then return false end
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    vim.api.nvim_buf_set_lines(bufnr, row, row, false, replacement)
    return true
end

function M.setup_buffer(bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, "MarkdownAddToc", function()
        M.add(bufnr)
    end, {})

    vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("markdown-toc-" .. bufnr, { clear = true }),
        buffer = bufnr,
        callback = function(args)
            if M.enabled then
                M.update(args.buf)
            end
        end,
    })
end

return M
