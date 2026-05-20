local config_dir = vim.fn.stdpath("config")
local git_pull = vim.fn.system("git -C " .. config_dir .. " pull --ff-only 2>&1")
if not git_pull:match("Already up to date") and not git_pull:match("error") and not git_pull:match("fatal") then
    vim.notify("Neovim config updated, reloading...", vim.log.levels.INFO)
    vim.cmd("source " .. config_dir .. "/init.lua")
    return
end

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
