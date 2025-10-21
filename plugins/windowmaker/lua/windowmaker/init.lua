local P = {}

function P.window(name, size)
    name = name or "Window"
    size = size or {
        x = 100,
        y = 100,
    }

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

    local opts = {
        relative = "editor",
        row = (vim.o.lines - size.y) / 2,
        col = (vim.o.columns - size.x) / 2,
        anchor = "NW",
        width = size.x,
        height = size.y,
        border = "rounded",
        title = name,
    }

    local win = vim.api.nvim_open_win(buf, true, opts)

    return {
        buf = buf,
        win = win,
    }
end

return P

