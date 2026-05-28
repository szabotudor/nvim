local P = {}

function P.tabulate_current()
    local win = vim.api.nvim_get_current_win()
    P.tabulate(win)
end

function P.tabulate(win)
    local cfg = vim.w[win].cfg
    if cfg == nil then
        cfg = { tabs = {} }
    end

    local tabs_container = {}

    tabs_container.buf = vim.api.nvim_create_buf(false, true)

    tabs_container.subwin = vim.api.nvim_open_win(-1, true, {
        anchor = "NW",
        border = "none",
        bufpos
    })

    vim.w[win].cfg = cfg
end

return P
