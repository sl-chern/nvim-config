local prettierd_or_biome = function()
    local biome_files = vim.fs.find({ "biome.json", "biome.jsonc" }, { upward = true, path = vim.fn.expand("%:p:h") })
    if #biome_files > 0 then
        return { "biome-check" }
    else
        return { "prettierd" }
    end
end

return {
    -- Main LSP Configuration
    "neovim/nvim-lspconfig",
    dependencies = {
        -- Automatically install LSPs and related tools to stdpath for Neovim
        { "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
        "williamboman/mason-lspconfig.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",

        -- Useful status updates for LSP.
        -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
        { "j-hui/fidget.nvim",       opts = {} },

        -- Allows extra capabilities provided by nvim-cmp
        "hrsh7th/cmp-nvim-lsp",
        {
            "stevearc/conform.nvim",
            opts = {
                formatters_by_ft = {
                    sql = { "sleek" },
                    python = { "ruff_format", "ruff_check" },
                    typescript = prettierd_or_biome,
                    typescriptreact = prettierd_or_biome,
                    javascript = prettierd_or_biome,
                    javascriptreact = prettierd_or_biome,
                    json = prettierd_or_biome,
                    css = prettierd_or_biome,
                },
                formatters = {
                    sleek = {
                        command = 'sleek',
                        args = { "--indent-spaces", "2", "--uppercase", "false", "--trailing-newline", "false" },
                    },
                    ruff_check = {
                        command = "ruff",
                        args = { "check", "--fix", "--exit-zero", "--stdin-filename", "$FILENAME", "-" },
                        stdin = true,
                    },
                },
            },
            keys = {
                {
                    "<leader>f",
                    function()
                        require("conform").format({ async = true, lsp_fallback = true })
                    end,
                },
            },
        }
    },
    config = function()
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
            callback = function(event)
                local map = function(keys, func, desc, mode)
                    mode = mode or "n"
                    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
                end

                -- Jump to the definition of the word under your cursor.
                --  This is where a variable was first declared, or where a function is defined, etc.
                --  To jump back, press <C-t>.
                map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

                -- Find references for the word under your cursor.
                map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

                -- Jump to the implementation of the word under your cursor.
                --  Useful when your language has ways of declaring types without an actual implementation.
                map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

                -- Jump to the type of the word under your cursor.
                --  Useful when you're not sure what type a variable is and you want to see
                --  the definition of its *type*, not where it was *defined*.
                map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

                -- Fuzzy find all the symbols in your current document.
                --  Symbols are things like variables, functions, types, etc.
                map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

                -- Fuzzy find all the symbols in your current workspace.
                --  Similar to document symbols, except searches over your entire project.
                map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

                -- Rename the variable under your cursor.
                --  Most Language Servers support renaming across files, etc.
                map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

                -- Execute a code action, usually your cursor needs to be on top of an error
                -- or a suggestion from your LSP for this to activate.
                map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

                -- WARN: This is not Goto Definition, this is Goto Declaration.
                --  For example, in C this would take you to the header.
                map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

                -- The following two autocommands are used to highlight references of the
                -- word under your cursor when your cursor rests there for a little while.
                --    See `:help CursorHold` for information about when this is executed
                --
                -- When you move your cursor, the highlights will be cleared (the second autocommand).
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                    local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
                    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.document_highlight,
                    })

                    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                        buffer = event.buf,
                        group = highlight_augroup,
                        callback = vim.lsp.buf.clear_references,
                    })

                    vim.api.nvim_create_autocmd("LspDetach", {
                        group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
                        callback = function(event2)
                            vim.lsp.buf.clear_references()
                            vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
                        end,
                    })
                end

                if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
                    map("<leader>th", function()
                        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
                    end, "[T]oggle Inlay [H]ints")
                end
            end,
        })

        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

        local servers = {
            ts_ls = {
                on_attach = function(client)
                    client.server_capabilities.documentFormattingProvider = false
                    client.server_capabilities.documentRangeFormattingProvider = false
                end
            },
            eslint = {},
            biome = {},
            zls = {},
            clangd = {},
            ruff = {},
            pylsp = {
                settings = {
                    pylsp = {
                        plugins = {
                            pyflakes = { enabled = false },
                            pycodestyle = { enabled = false },
                            autopep8 = { enabled = false },
                            yapf = { enabled = false },
                            mccabe = { enabled = false },
                            pylsp_mypy = { enabled = false },
                            pylsp_black = { enabled = false },
                            pylsp_isort = { enabled = false },
                        },
                    },
                },
            },
            html = { filetypes = { "html", "twig", "hbs" } },
            cssls = {},
            tailwindcss = {},
            dockerls = {},
            sqlls = {},
            terraformls = {},
            jsonls = {
                on_attach = function(client)
                    client.server_capabilities.documentFormattingProvider = false
                    client.server_capabilities.documentRangeFormattingProvider = false
                end
            },
            yamlls = {},
            lua_ls = {
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = "Replace",
                        },
                        runtime = { version = "LuaJIT" },
                        workspace = {
                            checkThirdParty = false,
                            library = {
                                "${3rd}/luv/library",
                                unpack(vim.api.nvim_get_runtime_file("", true)),
                            },
                        },
                        diagnostics = { disable = { "missing-fields" }, globals = { "vim" } },
                    },
                },
            },
            prismals = {},
        }

        vim.keymap.set("n", "gl", function()
            vim.diagnostic.open_float({ scope = "line" })
        end)

        vim.diagnostic.config({
            severity_sort = true,
            virtual_text = {
                severity = { min = vim.diagnostic.severity.WARN },
            },
            underline = {
                severity = { min = vim.diagnostic.severity.WARN },
            },
            severity = { min = vim.diagnostic.severity.WARN },
        })

        local ensure_installed = vim.tbl_keys(servers or {})
        require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

        for server, cfg in pairs(servers) do
            cfg.capabilities = vim.tbl_deep_extend("force", {}, capabilities, cfg.capabilities or {})
            vim.lsp.config(server, cfg)
            vim.lsp.enable(server)
        end
    end,
}
