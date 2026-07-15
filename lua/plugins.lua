return {
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = function()
            local dir = vim.fn.expand("~/.local/share/nvim/lazy/markdown-preview.nvim/app/")
            -- Change directory and run install.sh
            vim.fn.jobstart({ "sh", "./install.sh" }, {
                cwd = dir,
                stdout_buffered = true,
                stderr_buffered = true,
                on_stdout = function(_, data)
                    if data then print(table.concat(data, "\n")) end
                end,
                on_stderr = function(_, data)
                    if data then print(table.concat(data, "\n")) end
                end,
            })
        end,
    },

    {
        "nvim-tree/nvim-web-devicons",

        opts = {},
    },

    {
        "RaafatTurki/hex.nvim",

        opts = {
            is_file_binary_pre_read = function()
                return false
            end,
            is_file_binary_post_read = function()
                return false
            end,
        },
    },

    {
        "akinsho/toggleterm.nvim",

        version = "*",

        opts = {
            direction = "horizontal",
        },

        config = function(_, opts)
            local term = require("toggleterm")
            term.setup(opts)
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter",

        branch = "main",
        lazy = false,
        build = ":TSUpdate",

        opts = {
            ensure_installed = { "lua", "rust", "python", "cpp", "markdown", "html" },
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
                show_start = false,
                highlight = { "Function", "Label" },
            },
            indent = {
                char = { "･" },
            },
        },

        config = function(_, opts)
            local hooks = require("ibl.hooks")

            hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

            require("ibl").setup(opts)
        end
    },

    {
        "ya2s/nvim-cursorline",

        opts = {
            cursorline = {
                enable = true,
                timeout = 0,
                number = false,
            },
            cursorword = {
                enable = true,
                min_length = 3,
                hl = { underline = true },
            }
        },
    },

    {
        "nvim-tree/nvim-tree.lua",
        opts = {
            view = { width = 30 },

            on_attach = ON_ATTACH_NVIM_TREE,

            filters = {
                git_ignored = false,
                dotfiles = false,
            },
        },
        init = function()
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
        end,
    },

    {
        "saghen/blink.cmp",
        dependencies = { 'L3MON4D3/LuaSnip', 'taku25/blink-cmp-unreal' },
        version = "1.7",

        opts = {
            fuzzy = { implementation = "rust" },

            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
                providers = {
                    unreal = {
                        module = 'blink-cmp-unreal',
                        name = 'unreal',
                        score_offset = 10,
                    },
                },
            },

            snippets = { preset = "luasnip" },

            keymap = {
                ["<Tab>"] = {
                    function(cmp)
                        if cmp.is_visible() then return cmp.accept() end
                    end,
                    "fallback"
                }
            },
        },
    },

    {
        "saecki/crates.nvim",
        tag = "stable",
        config = true,
    },

    {
        "mfussenegger/nvim-dap",
    },

    {
        "nvimbugger",
        dependencies = { "mfussenegger/nvim-dap" },

        dir = vim.fn.stdpath("config") .. "/plugins/nvimbugger",

        opts = {
            rust = {
                adapter = {
                    name = "rust-gdb",
                    type = "executable",
                    command = vim.fn.stdpath("config") .. "/lua/lspadv/rust-gdb",
                    args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
                },
                defaults = {
                    name = "Debug",
                    type = "rust-gdb",
                    request = "launch",
                    args = {},
                    cwd = vim.fn.getcwd(),
                    target = "localhost:1234",
                    stopAtEntry = false,
                },
            },
        },
    },

    {
        "lewis6991/gitsigns.nvim",

        opts = {
            current_line_blame = true,
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
        tag = "v0.2.1",

        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "sharkdp/fd",
            "nvim-lua/plenary.nvim",
            "BurntSushi/ripgrep",
        },

        opts = {
        },
    },

    {
        'taku25/UnrealDev.nvim',
        -- Trigger loading on C++ file types or with the UDEV command
        ft = { "cpp", "c" }, 
        cmd = { "UDEV" }, 
        
        dependencies = {
            -- Recommended UI plugins
            "j-hui/fidget.nvim",
            "nvim-telescope/telescope.nvim",

            -- Core UnrealDev plugins
            { 
                'taku25/UNL.nvim', 
                lazy=false,
                build = "cargo build --release --manifest-path scanner/Cargo.toml"
            }, -- Required
            {
               'taku25/UEP.nvim',
            }, 
            'taku25/UBT.nvim',
            'taku25/UCM.nvim',
            'taku25/USH.nvim',
            'taku25/ULG.nvim',
            {
                'taku25/UNX.nvim', -- Logical View 
                dependencies = {
                  "MunifTanjim/nui.nvim",
                  "nvim-tree/nvim-web-devicons",
                },
            },

            -- Syntax and Parsers
            { 'taku25/USX.nvim', lazy=false }, -- Syntax highlighting
            {
              'romus204/tree-sitter-manager.nvim',
              opts = {
                ensure_installed = { "cpp", "ushader", "verse" },
                highlight        = { "cpp", "ushader", "verse" },
                border           = "rounded",
                languages = {
                  cpp = {
                    install_info = {
                      url              = "https://github.com/taku25/tree-sitter-cpp",
                      use_repo_queries = true,
                    },
                  },
                  ushader = {
                    install_info = {
                      url              = 'https://github.com/taku25/tree-sitter-unreal-shader',
                      use_repo_queries = true,
                    },
                  },
                  verse = {
                    install_info = {
                      url              = 'https://github.com/taku25/tree-sitter-verse',
                      use_repo_queries = true,
                    },
                  },
                },
              },
              config = function(_, opts)
                  local exists = vim.fn.executable("tree-sitter")
                  if not exists then
                      error("tree-sitter-cli isn't installed.\nInstall via `cargo install tree-sitter-cli`\n")
                  end
                vim.filetype.add({
                  extension = {
                    verse = "verse",
                    usf   = "ushader",
                    ush   = "ushader",
                  },
                })
                require("tree-sitter-manager").setup(opts)
                local group = vim.api.nvim_create_augroup('MyTreesitter', { clear = true })
                vim.api.nvim_create_autocmd('FileType', {
                  group    = group,
                  pattern  = opts.highlight,
                  callback = function(args)
                    vim.treesitter.start(args.buf)
                  end,
                })
              end,
            }
        },
        init = function()
            require("UnrealDev").setup({})
            -- Individual plugin settings can be configured here
            -- require('uep').setup { ... }
            -- require('ubt').setup { ... }
        end,
    },
}
