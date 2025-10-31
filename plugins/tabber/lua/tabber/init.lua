---@class TabsOpts
---@field tabsViewHeight number

---@class TabsBufs
---@field [number] number loaded buffers
---@field tabs number buffer for displaying list of tabs

---@class TabsWins
---@field content number
---@field tabs number

---@class TabsData
---@field bufs TabsBufs
---@field wins TabsWins
---@field autocmds table
---@field namespace any

---@class InterceptKey
---@field mode string
---@field map string
---@field action string|function|nil

---@class InterceptKeys
---@field [_] InterceptKey
---@field quit InterceptKey

---@type [TabsData]
local win_data = {}


local P = {}

function P.setup_intercept_key(buffer, key)
    vim.keymap.set(key.mode, key.map, function()
        if type(key.action) == "function" then
            key.action()
        else
            local termcodes = vim.api.nvim_replace_termcodes(
                key.action or key.map,
                true, false, true
            )
            vim.api.nvim_feedkeys(
                termcodes,
                key.mode,
                false
            )
        end
    end, { buffer = buffer, noremap = true, silent = true })
end

---@param buffer number
---@param intercept_keys table
function P.setup_intercept_keys(buffer, intercept_keys)
    for _, key in ipairs(intercept_keys) do
        P.setup_intercept_key(buffer, key)
    end
    for _, key in pairs(intercept_keys) do
        P.setup_intercept_key(buffer, key)
    end
end

---@param win number
---@return TabsData
function P.setup_internal_data(win)
    local tabs_buf = vim.api.nvim_create_buf(false, true)

    local tabs_win = vim.api.nvim_open_win(tabs_buf, false, {
        relative = "win",
        win = win,
        row = 0,
        col = 0,
        width = vim.api.nvim_win_get_width(win),
        height = P.opts.tabsViewHeight,
        border = "none",
        style = "minimal",
        focusable = false,
    })

    vim.api.nvim_win_set_var(tabs_win, "tabs", true)
    vim.api.nvim_win_set_var(win, "tabs", true)

    vim.api.nvim_buf_set_var(tabs_buf, "tabs", true)

    win_data[win] = {
        bufs = {
            tabs = tabs_buf,
        },
        wins = {
            content = win,
            tabs = tabs_win,
        },
        autocmds = {},
        namespace = nil,
    }
end

---@param data TabsData
function P.setup_autocmds(data, intercept_keys)
end

---@param data TabsData
function P.trigger_tabs_view_redraw(data)
    if not vim.api.nvim_buf_is_valid(data.bufs.tabs) then return end

    local view = { "" }
    data.namespace = data.namespace or vim.api.nvim_create_namespace("tabs")

    local highlights = {}
    for _, tab in ipairs(data.bufs) do
        local start = # view[1]

        local name = vim.api.nvim_buf_get_name(tab)
        local cwd = vim.loop.cwd()
        if name:sub(1, #cwd) == cwd then
            name = name:sub(#cwd + 2)
        end

        view[1] = view[1] .. "| " .. (tab == vim.api.nvim_win_get_buf(data.wins.content) and "● " or " ") .. name .. " "

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
        vim.api.nvim_buf_add_highlight(data.bufs.tabs, data.namespace, hl_group, line, hl.start, hl.stop)
    end
end

function P.close_tab()
    ---@class TabsData
    data = win_data[vim.api.nvim_get_current_win()]
    if not data then
        return
    end

    local tab_buf = vim.api.nvim_win_get_buf(data.wins.content)

    if # data.bufs == 1 then
        vim.api.nvim_exec_autocmds("WinClosed", { pattern = tostring(data.wins.content) })
        return
    end

    for i, buf in ipairs(data.bufs.content_bufs) do
        if buf == tab_buf then
            local switch_to = i - 1 > 0 and i - 1 or 2
            vim.api.nvim_set_current_win(data.wins.content)
            vim.api.nvim_win_set_buf(data.wins.content, data.bufs[switch_to])

            table.remove(data.bufs.content_bufs, i)
            vim.api.nvim_buf_delete(tab_buf, { force = true })
            break
        end
    end

    P.trigger_tabs_view_redraw(data)
end

function P.next_tab()
    ---@class TabsData
    data = win_data[vim.api.nvim_get_current_win()]

    if not data then return end

    local cur_buf = vim.api.nvim_win_get_buf(data.wins.content)

    for i, buf in ipairs(data.bufs.content_bufs) do
        if buf == cur_buf then
            if i == # data.bufs.content_bufs then
                vim.api.nvim_win_set_buf(data.wins.content, data.bufs.content_bufs[1])
            else
                vim.api.nvim_win_set_buf(data.wins.content, data.bufs.content_bufs[i + 1])
            end
        end
    end
end

function P.prev_tab()
    ---@class TabsData
    data = win_data[vim.api.nvim_get_current_win()]

    if not data then return end

    local cur_buf = vim.api.nvim_win_get_buf(data.wins.content)

    for i, buf in ipairs(data.bufs.content_bufs) do
        if buf == cur_buf then
            if i == 1 then
                vim.api.nvim_win_set_buf(data.wins.content, data.bufs.content_bufs[#data.bufs.content_bufs])
            else
                vim.api.nvim_win_set_buf(data.wins.content, data.bufs.content_bufs[i - 1])
            end
        end
    end
end

---@param old_win number
function P.tabulate_window(old_win, intercept_keys)
    local old_win_has_tabs, old_win_tabs = pcall(vim.api.nvim_win_get_var, old_win, "tabs")
    if old_win_has_tabs and old_win_tabs then
        print("Window is already a tabs window")
        return
    end

    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        ---@class TabsData
        data = win_data[vim.api.nvim_get_current_win()]
        if data then
            local old_buf = vim.api.nvim_win_get_buf(old_win)
            vim.api.nvim_win_close(old_win, true)
            vim.api.nvim_set_current_win(win)
            vim.api.nvim_win_set_buf(win, old_buf)
            return
        end
    end

    local data = P.setup_internal_data(old_win)
    win_data[old_win] = data

    P.setup_autocmds(data, intercept_keys)

    vim.api.nvim_set_current_win(data.wins.content)
end

---@param opts TabsOpts
function P.setup(opts)
    P.opts = opts
end

return P
