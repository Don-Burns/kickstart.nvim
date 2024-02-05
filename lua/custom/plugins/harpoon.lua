return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2", -- NOTE: This will be movalble to main branch in the future, check repo.
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    config = function()
        local harpoon = require("harpoon")

        harpoon:setup()
    end,
}
