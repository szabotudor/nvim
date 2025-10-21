return {
    {
        "nvim-tree/nvim-web-devicons",

        opts = {},
    },

    {
        "akinsho/toggleterm.nvim",

        version = "*",

        opts = {
            open_mapping = [[`]],
        },

        config = function (_, opts)
            local term = require("toggleterm")
            term.setup(opts)
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        tag = "v0.10.0",

        branch = "main",
        lazy = false,
        build = ":TSUpdate",

        opts = {
            indent = { enable = true },
            ensure_installed = { "lua", "rust", "python", "cpp", "markdown" },
            highlight = { enable = true },
        },
    },

    {
        "bluz71/vim-nightfly-colors",
        name = "nightfly",
        lazy = false,
        priority = 1000,
    },

    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",

        opts = {
            scope = {
                enabled = true,
                show_exact_scope = true,
                show_end = false,
                highlight = { "Function", "Label" },
            },
        },

        config = function (_, opts)
            local hooks = require("ibl.hooks")

            hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

            require("ibl").setup(opts)
        end
    },

    {
        "nvim-tree/nvim-tree.lua",
        opts = {
            view = { width = 30 },

            on_attach = ON_ATTACH_NVIM_TREE
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

    {
        "kdheepak/lazygit.nvim",
        lazy = true,
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        -- optional for floating window border decoration
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        -- setting the keybinding for LazyGit with 'keys' is recommended in
        -- order to load the plugin when the command is run for the first time
        keys = {
            { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
        }
    },

    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",

        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "sharkdp/fd",
            "nvim-lua/plenary.nvim",
            "BurntSushi/ripgrep",
        },

        opts = {
            buffer_previewer_maker = require('telescope.previewers').buffer_previewer_maker
        },
    },
}
