local P = {}

function P.tabulate_window(old_win, intercept_keys)
    local AUTOCMDS = {}

    local old_buf = vim.api.nvim_win_get_buf(old_win)

    local empty_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(old_win, empty_buf)

    local tabs_buf = vim.api.nvim_create_buf(false, true)
    local content_bufs = { [1] = old_buf }

    local tabs_win = vim.api.nvim_open_win(tabs_buf, true, {
        relative = "win",
        win = old_win,
        row = 0,
        col = 0,
        width = vim.api.nvim_win_get_width(old_win),
        height = 1,
        border = "none",
        style = "minimal",
    })

    local content_win = vim.api.nvim_open_win(old_buf, true, {
        relative = "win",
        win = tabs_win,
        row = vim.api.nvim_win_get_height(tabs_win),
        col = 0,
        width = vim.api.nvim_win_get_width(old_win),
        height = vim.api.nvim_win_get_height(old_win) - 1,
        border = "none",
    })

    AUTOCMDS.enter_autocmd = vim.api.nvim_create_autocmd("BufEnter", {
        buffer = empty_buf,
        callback = function()
            vim.api.nvim_set_current_win(content_win)
        end,
    })

    AUTOCMDS.closed_autocmd = vim.api.nvim_create_autocmd("WinClosed", {
        pattern = { tostring(old_win), tostring(tabs_win), tostring(content_win) },
        callback = function()
            if not vim.api.nvim_win_is_valid(old_win) then
                vim.api.nvim_win_close(tabs_win, true)
                vim.api.nvim_win_close(content_win, true)
            elseif not vim.api.nvim_win_is_valid(tabs_win) then
                vim.api.nvim_win_close(old_win, true)
                vim.api.nvim_win_close(content_win, true)
            elseif not vim.api.nvim_win_is_valid(content_win) then
                vim.api.nvim_win_close(old_win, true)
                vim.api.nvim_win_close(tabs_win, true)
            end

            vim.api.nvim_del_autocmd(AUTOCMDS.enter_autocmd)
            vim.api.nvim_del_autocmd(AUTOCMDS.closed_autocmd)

            vim.api.nvim_buf_delete(empty_buf, { force = true })
            vim.api.nvim_buf_delete(tabs_buf, { force = true })
            for _, buf in ipairs(content_bufs) do
                vim.api.nvim_buf_delete(buf, { force = true })
            end
        end
    })

    vim.api.nvim_set_current_win(content_win)
end

function P.setup(opts)
end

return P
