local P = {}

function P.tabulate_current()
    local win = vim.api.nvim_get_current_win()
    P.tabulate(win)
end

---@class TabInfo
---@field buf integer Buffer associated with this tab
---@field name string Tab name (to show in the tab list)
local TabInfo = {}
function TabInfo.new()
    local self = setmetatable({
        buf = -1,
        name = "",
    }, TabInfo)
    return self
end

---@class WinCfgWins
---@field orig integer Original Window
---@field subwin integer Dummy window floating over original
local WinCfgWin = {}
function WinCfgWin.new()
    local self = setmetatable({
        orig = -1,
        subwin = -1,
    }, WinCfgWin)
    return self
end

---@class WinCfg
---@field tabs [TabInfo] List of tabs
---@field wins WinCfgWins Window data
---@field tabs_buf integer Tabs list buffer (to show tabs list)
local WinCfg = {}
function WinCfg.new()
    local self = setmetatable({
        tabs = {},
        wins = WinCfgWin.new(),
        buf_tabs = -1,
    }, WinCfg)
    return self
end

---@param cfg WinCfg
local function draw_tabs(cfg)
    local show = ""
    for i, tab in ipairs(cfg.tabs) do
        show = show .. tab.name .. (i ~= #cfg.tabs and " | " or "")
    end

    vim.api.nvim_buf_set_lines(cfg.tabs_buf, 0, 0, false, { show })
end

function P.tabulate(win)
    ---@type WinCfg
    local cfg = vim.w[win].cfg or WinCfg.new()

    if cfg.wins.new == win or cfg.wins.orig == win then
        print("Window is already a tabs window\n")
        return
    end

    cfg.wins.orig = win
    local orig_win_config = vim.api.nvim_win_get_config(cfg.wins.orig)

    cfg.tabs_buf = vim.api.nvim_create_buf(false, true)

    local orig_buf = vim.api.nvim_win_get_buf(win)
    cfg.wins.subwin = vim.api.nvim_open_win(orig_buf, true, {
        anchor = "NW",
        border = "none",
        relative = "win",
        win = win,
        row = 1,
        col = 0,
        width = orig_win_config.width,
        height = orig_win_config.height - 1,
    })

    cfg.wins.orig = win

    vim.api.nvim_win_set_buf(win, cfg.tabs_buf)
    vim.api.nvim_win_set_buf(cfg.wins.subwin, orig_buf)

    cfg.tabs[1] = TabInfo.new()
    cfg.tabs[1].buf = orig_buf

    local full_name = vim.api.nvim_buf_get_name(orig_buf)
    cfg.tabs[1].name = full_name:match(".*/(.+)")

    orig_win_config.style = "minimal"
    vim.api.nvim_win_set_config(win, orig_win_config)

    draw_tabs(cfg)

    vim.w[win].cfg = cfg
    vim.w[cfg.wins.subwin].cfg = cfg
end

return P
