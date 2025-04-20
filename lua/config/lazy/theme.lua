return {
    {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            require("rose-pine").setup({
                dark_variant = "moon",
                disable_background = true,
                extend_background_behind_borders = false,
                styles = {
                    italic = false,
                    transparency = true,
                },
                highlight_groups = {
                    Pmenu = { bg = "surface" },
                    NormalFloat = { bg = "surface" },
                    TelescopeSelectionCaret = { fg = "rose", bg = "rose" },
                },
            })
            vim.cmd("colorscheme rose-pine")
        end,
    },
}
