vim.opt.termguicolors = true
vim.g.nightflyCursorColor = true
vim.g.nightflyNormalPmenu = true
vim.g.nightflyNormalFloat = true

require("settings")

require("lazy-nvim")

require("lspcfg")

vim.cmd [[colorscheme nightfly]]
vim.o.winborder = "single"
vim.opt.fillchars = {
    horiz = '━',
    horizup = '┻',
    horizdown = '┳',
    vert = '┃',
    vertleft = '┫',
    vertright = '┣',
    verthoriz =
    '╋',
}
