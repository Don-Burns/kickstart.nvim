-- ftplugin/markdown.lua can run more than once for the same buffer (:e,
-- re-detected filetype, etc). Guard so we don't redo setup_buffer's work
-- every time -- setup_buffer's autocmd is idempotent (clear = true per
-- bufnr) but this avoids the redundant command/autocmd re-registration.
if vim.b.did_markdown_toc then
    return
end
vim.b.did_markdown_toc = true

require("custom.markdown_toc").setup_buffer(vim.api.nvim_get_current_buf())
