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
}
