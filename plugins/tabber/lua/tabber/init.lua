---@class TabsOpts
---@field tabsViewHeight number

---@class TabsBufs
---@field empty number buffer for the dummy window
---@field tabs number buffer for displaying list of tabs
---@field contents [number] List of buffers (tabs)

---@class TabsWins
---@field dummy number
---@field content number
---@field tabs number

---@class TabsData
---@field bufs TabsBufs
---@field wins TabsWins
---@field AUTOCMDS table
---@field ns any

---@class InterceptKey
---@field mode string
---@field map string
---@field action string|function|nil

---@class InterceptKeys
---@field [_] InterceptKey
---@field quit InterceptKey


local P = {}

---@param data TabsData
---@param buffer number
---@param intercept_keys table
function P.setup_intercept_keys(data, buffer, intercept_keys)
    for _, key in ipairs(intercept_keys) do
        vim.keymap.set(key.mode, key.map, function()
            vim.api.nvim_win_set_var(data.wins.dummy, "redirect", key)
            vim.api.nvim_set_current_win(data.wins.dummy)
        end, {
            buffer = buffer,
            remap = true,
        })
    end

    if intercept_keys.quit then
        vim.keymap.set(intercept_keys.quit.mode, intercept_keys.quit.map, function()
            if not intercept_keys.quit.action then
                P.close_tab(data, buffer)
            elseif type(intercept_keys.quit.action) == "function" then
                intercept_keys.quit.action()
            else
                local termcodes = vim.api.nvim_replace_termcodes(
                    intercept_keys.quit.action or intercept_keys.quit.map,
                    true, false, true
                )
                vim.api.nvim_feedkeys(
                    termcodes,
                    intercept_keys.quit.mode,
                    false
                )
            end
        end, { buffer = buffer, noremap = true, silent = true })
    end
end

---@param old_win number
---@return TabsData
function P.setup_internal_data(old_win)
    local old_buf = vim.api.nvim_win_get_buf(old_win)

    local empty_buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(old_win, empty_buf)
    vim.api.nvim_buf_set_name(empty_buf, "Tabs")

    local tabs_buf = vim.api.nvim_create_buf(false, true)

    local tabs_win = vim.api.nvim_open_win(tabs_buf, false, {
        relative = "win",
        win = old_win,
        row = 0,
        col = 0,
        width = vim.api.nvim_win_get_width(old_win),
        height = P.opts.tabsViewHeight,
        border = "none",
        style = "minimal",
        focusable = false,
    })
    vim.api.nvim_set_option_value("winhighlight", "Normal:Normal", { win = tabs_win })

    local content_win = vim.api.nvim_open_win(old_buf, false, {
        relative = "win",
        win = tabs_win,
        row = P.opts.tabsViewHeight,
        col = 0,
        width = vim.api.nvim_win_get_width(old_win),
        height = vim.api.nvim_win_get_height(old_win) - P.opts.tabsViewHeight,
        border = "none",
    })

    vim.api.nvim_win_set_var(tabs_win, "tabs", true)
    vim.api.nvim_win_set_var(content_win, "tabs", true)
    vim.api.nvim_win_set_var(content_win, "tabscontent", true)
    vim.api.nvim_win_set_var(old_win, "tabs", true)

    vim.api.nvim_buf_set_var(empty_buf, "tabs", true)
    vim.api.nvim_buf_set_var(tabs_buf, "tabs", true)

    return {
        bufs = {
            empty = empty_buf,
            contents = {},
            tabs = tabs_buf,
        },
        wins = {
            dummy = old_win,
            content = content_win,
            tabs = tabs_win,
        },
        AUTOCMDS = {},
    }
end

---@param data TabsData
function P.setup_autocmds(data, intercept_keys)
    data.AUTOCMDS.enter_autocmd = vim.api.nvim_create_autocmd("BufEnter", {
        buffer = data.bufs.empty,
        callback = function()
            local cur_win = vim.api.nvim_get_current_win()
            if cur_win ~= data.wins.dummy then
                return
            end

            local has_redirect, key = pcall(vim.api.nvim_win_get_var, cur_win, "redirect")
            if has_redirect then
                vim.api.nvim_win_del_var(cur_win, "redirect")
                if type(key.action) == "function" then
                    key.action()
                else
                    local termcodes = vim.api.nvim_replace_termcodes(key.action or key.map, true, false, true)
                    vim.api.nvim_feedkeys(
                        termcodes,
                        key.mode,
                        false
                    )
                end
            else
                vim.api.nvim_set_current_win(data.wins.content)
            end

            P.trigger_tabs_view_redraw(data)
        end,
    })

    data.AUTOCMDS.leave_buf_autocmd = vim.api.nvim_create_autocmd("BufLeave", {
        callback = function()
            local cur_win = vim.api.nvim_get_current_win()
            local cur_buf = vim.api.nvim_win_get_buf(cur_win)

            local cursor = vim.api.nvim_win_get_cursor(cur_win)

            vim.api.nvim_buf_set_var(cur_buf, "buf_data", {
                cursor = cursor,
            })
        end
    })

    data.AUTOCMDS.open_buf_autocmd = vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
            if vim.api.nvim_get_current_buf() == data.bufs.empty then
                return
            end

            local cur_win = vim.api.nvim_get_current_win()

            local has_tabs, tabs = pcall(vim.api.nvim_win_get_var, cur_win, "tabs")
            if not (has_tabs and tabs) then return end

            local new_buf = vim.api.nvim_win_get_buf(cur_win)

            local buf_has_tabs, buf_tabs = pcall(vim.api.nvim_buf_get_var, new_buf, "tabs")
            if buf_has_tabs and buf_tabs then
                local has_buf_data, buf_data = pcall(vim.api.nvim_buf_get_var, new_buf, "buf_data")
                if has_buf_data then
                    vim.api.nvim_win_set_cursor(cur_win, buf_data.cursor)
                    vim.cmd [[normal! zz]]
                end

                P.trigger_tabs_view_redraw(data)
                return
            end

            data.bufs.contents[#data.bufs.contents + 1] = new_buf
            vim.api.nvim_buf_set_var(new_buf, "tabs", true)
            P.setup_intercept_keys(data, new_buf, intercept_keys)

            if cur_win == data.wins.dummy then
                vim.api.nvim_win_set_buf(cur_win, data.bufs.empty)
            elseif cur_win == data.wins.tabs then
                vim.api.nvim_win_set_buf(data.wins.tabs, data.bufs.tabs)
            end

            vim.api.nvim_win_set_buf(data.wins.content, new_buf)
            vim.api.nvim_set_option_value("winhighlight", "Normal:Normal", { win = cur_win })

            P.trigger_tabs_view_redraw(data)
        end,
    })

    data.AUTOCMDS.closed_autocmd = vim.api.nvim_create_autocmd("WinClosed", {
        pattern = { tostring(data.wins.dummy), tostring(data.wins.tabs), tostring(data.wins.content) },
        callback = function()
            if vim.api.nvim_win_is_valid(data.wins.dummy) then
                vim.api.nvim_win_close(data.wins.dummy, true)
            end
            if vim.api.nvim_win_is_valid(data.wins.content) then
                vim.api.nvim_win_close(data.wins.content, true)
            end
            if vim.api.nvim_win_is_valid(data.wins.tabs) then
                vim.api.nvim_win_close(data.wins.tabs, true)
            end

            for _, cmd in pairs(data.AUTOCMDS) do
                vim.api.nvim_del_autocmd(cmd)
            end

            vim.api.nvim_buf_delete(data.bufs.empty, { force = true })
            vim.api.nvim_buf_delete(data.bufs.tabs, { force = true })
            for _, buf in ipairs(data.bufs.contents) do
                vim.api.nvim_buf_delete(buf, { force = true })
            end

            P.trigger_tabs_view_redraw(data)
        end
    })

    data.AUTOCMDS.resized_autocmd = vim.api.nvim_create_autocmd("WinResized", {
        callback = function()
            local tabs_config = vim.api.nvim_win_get_config(data.wins.tabs)
            tabs_config.row = 0
            tabs_config.col = 0
            tabs_config.width = vim.api.nvim_win_get_width(data.wins.dummy)
            tabs_config.height = P.opts.tabsViewHeight
            vim.api.nvim_win_set_config(data.wins.tabs, tabs_config)

            local content_config = vim.api.nvim_win_get_config(data.wins.content)
            content_config.row = P.opts.tabsViewHeight
            content_config.col = 0
            content_config.width = vim.api.nvim_win_get_width(data.wins.dummy)
            content_config.height = vim.api.nvim_win_get_height(data.wins.dummy) - P.opts.tabsViewHeight
            vim.api.nvim_win_set_config(data.wins.content, content_config)

            P.trigger_tabs_view_redraw(data)
        end,
    })
end

---@param data TabsData
function P.trigger_tabs_view_redraw(data)
    if not vim.api.nvim_buf_is_valid(data.bufs.tabs) then return end

    local view = { "" }
    data.ns = data.ns or vim.api.nvim_create_namespace("tabs")

    local highlights = {}
    for i, tab in ipairs(data.bufs.contents) do
        local start = # view[1]

        local name = vim.api.nvim_buf_get_name(tab)
        local cwd = vim.loop.cwd()
        if name:sub(1, #cwd) == cwd then
            name = name:sub(#cwd + 2)
        end

        view[1] = view[1] .. "| " .. tostring(i) .. " " .. name .. " "

        local stop = # view[1]

        highlights[#highlights + 1] = { start = start + 2, stop = stop - 1, tab = tab }
    end
    view[1] = view[1] .. "|"

    vim.api.nvim_buf_set_lines(
        data.bufs.tabs,
        0,
        -1,
        false,
        view
    )

    local line = 0
    for _, hl in ipairs(highlights) do
        local hl_group = (hl.tab == vim.api.nvim_get_current_buf()) and "@variable" or "Comment"
        ---@diagnostic disable-next-line: deprecated
        vim.api.nvim_buf_add_highlight(data.bufs.tabs, data.ns, hl_group, line, hl.start, hl.stop)
    end

    vim.api.nvim_win_set_var(data.wins.content, "tabsdata", data)
end

---@param data TabsData
---@param tab_buf number
function P.close_tab(data, tab_buf)
    if # data.bufs.contents == 1 then
        vim.api.nvim_exec_autocmds("WinClosed", { pattern = tostring(data.wins.dummy) })
        return
    end

    for i, buf in ipairs(data.bufs.contents) do
        if buf == tab_buf then
            local switch_to = i - 1 > 0 and i - 1 or 2
            vim.api.nvim_set_current_win(data.wins.content)
            vim.api.nvim_set_current_buf(data.bufs.contents[switch_to])

            table.remove(data.bufs.contents, i)
            vim.api.nvim_buf_delete(tab_buf, { force = true })
            break
        end
    end

    P.trigger_tabs_view_redraw(data)
end

function P.next_tab()
    local has_data,
    ---@class TabsData
    data = pcall(vim.api.nvim_win_get_var, vim.api.nvim_get_current_win(), "tabsdata")

    if not has_data then return end

    local cur_buf = vim.api.nvim_win_get_buf(data.wins.content)

    for i, buf in ipairs(data.bufs.contents) do
        if buf == cur_buf then
            if i == # data.bufs.contents then
                vim.api.nvim_win_set_buf(data.wins.content, data.bufs.contents[1])
            else
                vim.api.nvim_win_set_buf(data.wins.content, data.bufs.contents[i + 1])
            end
        end
    end
end

function P.prev_tab()
    local has_data,
    ---@class TabsData
    data = pcall(vim.api.nvim_win_get_var, vim.api.nvim_get_current_win(), "tabsdata")

    if not has_data then return end

    local cur_buf = vim.api.nvim_win_get_buf(data.wins.content)

    for i, buf in ipairs(data.bufs.contents) do
        if buf == cur_buf then
            if i == 1 then
                vim.api.nvim_win_set_buf(data.wins.content, data.bufs.contents[#data.bufs.contents])
            else
                vim.api.nvim_win_set_buf(data.wins.content, data.bufs.contents[i - 1])
            end
        end
    end
end

---@param old_win number
---@param intercept_keys InterceptKeys
function P.tabulate_window(old_win, intercept_keys)
    local old_win_has_tabs, old_win_tabs = pcall(vim.api.nvim_win_get_var, old_win, "tabs")
    if old_win_has_tabs and old_win_tabs then
        print("Window is already a tabs window")
        return
    end

    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local has_tabs, tabs = pcall(vim.api.nvim_win_get_var, win, "tabscontent")
        if has_tabs and tabs then
            local old_buf = vim.api.nvim_win_get_buf(old_win)
            vim.api.nvim_win_close(old_win, true)
            vim.api.nvim_set_current_win(win)
            vim.api.nvim_win_set_buf(win, old_buf)
            return
        end
    end

    local data = P.setup_internal_data(old_win)
    vim.api.nvim_win_set_var(data.wins.content, "tabsdata", data)

    P.setup_autocmds(data, intercept_keys)

    vim.api.nvim_set_current_win(data.wins.content)
end

---@param opts TabsOpts
function P.setup(opts)
    P.opts = opts
end

return P
