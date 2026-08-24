return {
    "romus204/tree-sitter-manager.nvim",
    dependencies = {}, -- tree-sitter CLI must be installed system-wide
    config = function()
        require("tree-sitter-manager").setup({
            ensure_installed = {
                "lua",
                "python",
                "javascript",
                "typescript",
                "tsx",
                "vimdoc",
                "vim",
                "regex",
                "sql",
                "dockerfile",
                "toml",
                "json",
                "go",
                "gitignore",
                "graphql",
                "yaml",
                "make",
                "cmake",
                "markdown",
                "markdown_inline",
                "bash",
                "css",
                "html",
                "caddy"
            },
            auto_install = true, -- if enabled, install missing parsers when editing a new file
            highlight = true,    -- treesitter highlighting is enabled by default
            -- languages = {}, -- override or add new parser sources
        })
    end
}
