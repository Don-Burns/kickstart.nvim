-- For "normal" vim setings
return {
    apply_options = function()
        -- Set <space> as the leader key
        -- See `:help mapleader`
        --  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
        vim.g.mapleader = " "
        vim.g.maplocalleader = " "
        vim.o.scrolloff = 15
    end
}
