return {
    "stevearc/oil.nvim",
    dependencies = { { "nvim-tree/nvim-web-devicons", opts = {} } },
    config = function()
        local detail = false

        require("oil").setup({
            view_options = {
                show_hidden = true,
                is_hidden_file = function(name, bufnr)
                    return false
                end,
            },
            skip_confirm_for_simple_edits = true,
            watch_for_changes = true,
            keymaps = {
                ["g?"] = { "actions.show_help", mode = "n" },
                ["<CR>"] = "actions.select",
                ["<C-s>"] = { "actions.select", opts = { vertical = true } },
                ["<C-t>"] = { "actions.select", opts = { tab = true } },
                ["<C-v>"] = { "actions.preview", opts = { split = "botright" } },
                ["<C-c>"] = { "actions.close", mode = "n" },
                ["-"] = { "actions.parent", mode = "n" },
                ["_"] = { "actions.open_cwd", mode = "n" },
                ["`"] = { "actions.cd", mode = "n" },
                ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
                ["gs"] = { "actions.change_sort", mode = "n" },
                ["gx"] = "actions.open_external",
                ["g."] = { "actions.toggle_hidden", mode = "n" },
                ["g\\"] = { "actions.toggle_trash", mode = "n" },
                ["gd"] = {
                    desc = "Toggle file detail view",
                    callback = function()
                        detail = not detail
                        if detail then
                            require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
                        else
                            require("oil").set_columns({ "icon" })
                        end
                    end,
                },
            },
            use_default_keymaps = false,
        })

        vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory" })
    end,
}
