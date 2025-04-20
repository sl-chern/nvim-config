return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    config = function()
        require("neo-tree").setup({
            filesystem = {
                hijack_netrw_behavior = "disabled",
            },
        })
        vim.keymap.set("n", "<leader>nt", "<cmd>Neotree toggle<CR>")
    end,
}
