-- GitHub PR and issue management plugin for Neovim
return {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        picker = "telescope",
        use_local_fs = true,
    },
    keys = {
        { "<leader>gp", "<cmd>Octo pr list<cr>", desc = "List GitHub pull requests" },
        { "<leader>gr", "<cmd>Octo review<cr>",  desc = "Review current pull request" },
    },
}
