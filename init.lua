require("settings")

require("lazy-nvim")

require("lspcfg")

vim.cmd [[colorscheme nightfly]]
vim.g.nifghtflyCursorColor = true
vim.g.nightflyNormalPmenu = true
vim.g.nightflyNormalFloat = true
vim.o.winborder = "single"
vim.opt.fillchars = { horiz = '━', horizup = '┻', horizdown = '┳', vert = '┃', vertleft = '┫', vertright = '┣', verthoriz = '╋', }

