return {
    "nvimtools/none-ls.nvim",
    dependencies = {
        "nvimtools/none-ls-extras.nvim",
        "jayp0521/mason-null-ls.nvim",
    },
    config = function()
        local null_ls = require("null-ls")
        local formatting = null_ls.builtins.formatting
        local diagnostics = null_ls.builtins.diagnostics

        -- Formatters & linters for mason to install
        require("mason-null-ls").setup({
            ensure_installed = {
                "prettierd",
                "stylua",
                "eslint-lsp",
                "shfmt",
                "ruff",
            },
            automatic_installation = true,
        })

        local sources = {
            formatting.prisma_format,
            formatting.prettierd,
            formatting.stylua.with({ extra_args = { "--indent-type", "Spaces" } }),
            formatting.shfmt.with({ args = { "-i", "4" } }),
            formatting.terraform_fmt,
            require("none-ls.formatting.ruff").with({ extra_args = { "--extend-select", "I" } }),
            require("none-ls.formatting.ruff_format"),
        }

        vim.keymap.set("n", "<leader>f", function()
            vim.lsp.buf.format({
                async = false,
                -- TODO: prisma formtting not working
                filter = function(c)
                    return c.name == "null-ls"
                end,
            })
        end)

        local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
        null_ls.setup({
            -- debug = true, -- Enable debug mode. Inspect logs with :NullLsLog.
            sources = sources,
            -- you can reuse a shared lspconfig on_attach callback here
            -- on_attach = function(client, bufnr)
            --     if client.supports_method("textDocument/formatting") then
            --         vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            --         vim.api.nvim_create_autocmd("BufWritePre", {
            --             group = augroup,
            --             buffer = bufnr,
            --             callback = function()
            --                 vim.lsp.buf.format({
            --                     async = false,
            --                     filter = function(c)
            --                         return c.name == "null-ls"
            --                     end,
            --                 })
            --             end,
            --         })
            --     end
            -- end,
        })
    end,
}
