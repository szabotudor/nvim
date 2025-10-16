return {
    {
        "nvim-tree/nvim-tree.lua",
        opts = {
            view = { width = 30 },
        },
        init = function()
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
            vim.opt.termguicolors = true
        end,
    },

    {
        "saghen/blink.cmp",
dependencies = { 'L3MON4D3/LuaSnip' },
        version = "1.7",

        opts = {
            fuzzy = { implementation = "rust" },

            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
            },

            snippets = { preset = "luasnip" },

            keymap = {
                ["<Tab>"] = {
                    function (cmp)
                        if cmp.is_visible() then return cmp.accept() end
                    end,
                    "fallback"
                }
            },
        },
    },
}
