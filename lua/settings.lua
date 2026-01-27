-- SETTINGS

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.number = true


-- KEYMAP


-- Cleanup

vim.keymap.set("n", "<C-d>", "<Nop>")
vim.keymap.set("n", "<C-u>", "<Nop>")


-- Deleting
vim.keymap.set({ "n", "v" }, "<S-d>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<Del>", "d", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<S-Del>", "dd", { noremap = true, silent = true })

-- Enter insert mode
vim.keymap.set("n", "<S-a>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "e", "i", { noremap = true, silent = true })
vim.keymap.set("n", "<S-e>", "a", { noremap = true, silent = true })
vim.keymap.set("n", "<C-e>", "<S-a>", { noremap = true, silent = true })

-- Block select
vim.keymap.set("n", "<S-v>", "Nop")
vim.keymap.set("n", "v", "Nop")
vim.keymap.set("n", "v", "v", { noremap = true, silent = true })
vim.keymap.set("n", "<S-v>", "<S-v>", { noremap = true, silent = true })
vim.keymap.set("n", "<S-v><S-v>", "<C-v>", { noremap = true, silent = true })
vim.keymap.set("n", "<S-v>v", "<C-v>", { noremap = true, silent = true })

local function insert_sym(sym, end_sym)
    if vim.fn.visualmode() ~= "v" then
        return
    end

    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
        "n",
        false
    )

    vim.schedule(function()
        local bufnr = 0
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")

        vim.api.nvim_buf_set_text(
            bufnr,
            end_pos[2] - 1,
            end_pos[3],
            end_pos[2] - 1,
            end_pos[3],
            { end_sym }
        )

        vim.api.nvim_buf_set_text(
            bufnr,
            start_pos[2] - 1,
            start_pos[3] - 1,
            start_pos[2] - 1,
            start_pos[3] - 1,
            { sym }
        )
    end)
end

vim.keymap.set("v", "(", function()
    insert_sym("(", ")")
end, { silent = true, noremap = true })

vim.keymap.set("v", "[", function()
    insert_sym("[", "]")
end, { silent = true, noremap = true })

vim.keymap.set("v", "[[", function()
    insert_sym("[", "]")
end, { silent = true, noremap = true })

vim.keymap.set("v", "{", function()
    insert_sym("{", "}")
end, { silent = true, noremap = true })

-- Undo/redo
vim.keymap.set({ "n", "i", "s" }, "<C-z>", function() vim.cmd("undo") end, { noremap = true, silent = true })
vim.keymap.set({ "n", "i", "s" }, "<C-y>", function() vim.cmd("redo") end, { noremap = true, silent = true })
vim.keymap.set({ "n", "i", "s" }, "<C-r>", function() vim.cmd("redo") end, { noremap = true, silent = true })

-- Copy/cut in normal and visual mode
vim.keymap.set({ "n", "v" }, "<C-c>", '"+y', { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<C-x>", '"+d', { noremap = true, silent = true })

-- Paste in insert mode
vim.keymap.set({ "i" }, "<C-v>", function()
    vim.api.nvim_put({ vim.fn.getreg('+') }, 'c', true, true)
end, { noremap = true, silent = true })

-- Paste in normal mode
vim.keymap.set({ "n" }, "<C-v>", function()
    vim.cmd('normal! "+P')
end)


-- Quitting

vim.keymap.set({ "n" }, "q", function()
    vim.cmd("confirm quit")
end, { noremap = true, silent = true })

vim.keymap.set({ "n" }, "Q", function()
    if vim.bo.modified then
        vim.cmd("confirm q!")
    else
        vim.cmd("q!")
    end
end, { noremap = true, silent = true })

vim.keymap.set("n", "<C-q>", function()
    vim.cmd [[tabclose]]
end)


-- Saving

vim.keymap.set({ "n", "v", "i" }, "<C-s>", function()
    vim.cmd("write")
end, { noremap = true, silent = true })

vim.keymap.set({ "n", "v" }, "<S-s>", function()
    vim.cmd("wall")
end, { noremap = true, silent = true })


-- Moving

vim.keymap.set({ "n", "v" }, "w", "k", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "s", "j", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "a", "h", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "d", "l", { noremap = true, silent = true })

local move10 = {
    ["<S-Up>"] = "10k",
    ["<S-Down>"] = "10j",
    ["<S-Left>"] = "10h",
    ["<S-Right>"] = "10l",
}

for key, cmd in pairs(move10) do
    vim.keymap.set({ "n", "v" }, key, cmd, { noremap = true, silent = true })

    vim.keymap.set({ "i" }, key, "<C-o>" .. cmd, { noremap = true, silent = true })
end


-- Window navigation

vim.keymap.set("n", "<C-w>s", "Nop")
vim.keymap.set("n", "<C-w>h", "<C-w>s")

local function resize_window(dir, delta)
    local win = vim.api.nvim_get_current_win()

    delta = vim.v.count > 0 and vim.v.count * delta or delta

    if dir == "v" then
        vim.api.nvim_win_set_height(win,
            vim.api.nvim_win_get_height(win) +
            math.floor(delta ~= 0 and
                (delta * (vim.v.count ~= 0 and 1 or math.floor(vim.api.nvim_win_get_height(win) * 0.2))) or 9999))
    elseif dir == "h" then
        vim.api.nvim_win_set_width(win,
            vim.api.nvim_win_get_width(win) +
            math.floor(delta ~= 0 and
                (delta * (vim.v.count ~= 0 and 1 or math.floor(vim.api.nvim_win_get_width(win) * 0.2))) or 9999))
    end
end

local function move_window(dir)
    local win = vim.api.nvim_get_current_win()
    local nwin = vim.fn.winnr(dir)

    if nwin == 0 or nwin == win then
        return
    end

    nwin = vim.fn.win_getid(nwin)
    local nwin_type = vim.api.nvim_get_option_value("filetype", { buf = vim.api.nvim_win_get_buf(nwin) })
    if nwin_type:find("NvimTree") ~= nil then
        return
    end

    local cursor = vim.api.nvim_win_get_cursor(win)
    local ncursor = vim.api.nvim_win_get_cursor(nwin)

    local buf = vim.api.nvim_win_get_buf(win)
    local nbuf = vim.api.nvim_win_get_buf(nwin)
    vim.api.nvim_win_set_buf(win, nbuf)
    vim.api.nvim_win_set_buf(nwin, buf)

    vim.api.nvim_set_current_win(nwin)
    vim.api.nvim_win_set_cursor(nwin, cursor)
    vim.api.nvim_win_set_cursor(win, ncursor)
end

vim.keymap.set("n", "<C-w>gv", function()
    resize_window("v", 1)
end, { noremap = true, silent = true })

vim.keymap.set("n", "<C-w>gh", function()
    resize_window("h", 1)
end, { noremap = true, silent = true })

vim.keymap.set("n", "<C-w>gg", function()
    resize_window("v", 1)
    resize_window("h", 1)
end, { noremap = true, silent = true })


vim.keymap.set("n", "<C-w>sv", function()
    resize_window("v", -1)
end, { noremap = true, silent = true })

vim.keymap.set("n", "<C-w>sh", function()
    resize_window("h", -1)
end, { noremap = true, silent = true })

vim.keymap.set("n", "<C-w>ss", function()
    resize_window("v", -1)
    resize_window("h", -1)
end, { noremap = true, silent = true })


vim.keymap.set("n", "<C-w>mv", function()
    resize_window("v", 0)
end, { noremap = true, silent = true })

vim.keymap.set("n", "<C-w>mh", function()
    resize_window("h", 0)
end, { noremap = true, silent = true })

vim.keymap.set("n", "<C-w>mm", function()
    resize_window("v", 0)
    resize_window("h", 0)
end, { noremap = true, silent = true })


vim.keymap.set("n", "<C-w><C-Up>", function()
    move_window("k")
end, { noremap = true, silent = true })
vim.keymap.set("n", "<C-w><C-Down>", function()
    move_window("j")
end, { noremap = true, silent = true })
vim.keymap.set("n", "<C-w><C-Left>", function()
    move_window("h")
end, { noremap = true, silent = true })
vim.keymap.set("n", "<C-w><C-Right>", function()
    move_window("l")
end, { noremap = true, silent = true })


-- Session

local function ensure_session()
    local session_dir = vim.fn.getcwd() .. "/.nvim/session0"
    if not (vim.loop or vim.uv).fs_stat(session_dir) then
        vim.fn.system({ "mkdir", "-p", session_dir })
        print("Created local directory '" .. session_dir .. "'")
    end
    return session_dir
end

for i = 0, 9 do
    local si = tostring(i)
    vim.keymap.set("n", si .. "s", function()
        local session_dir = ensure_session()
        vim.cmd [[NvimTreeClose]]
        vim.cmd("mks! " .. session_dir .. "/tab" .. si)
    end)
    vim.keymap.set("n", si .. "o", function()
        local session_dir = ensure_session()
        vim.cmd("source " .. session_dir .. "/tab" .. si)
        vim.cmd [[NvimTreeOpen]]
    end)
    vim.keymap.set("n", si .. "q", function()
        vim.cmd [[NvimTreeClose]]
        local session_dir = ensure_session()
        vim.cmd("mks! " .. session_dir .. "/tab" .. si)
        vim.cmd [[qa!]]
    end)
end


-- Tab navigation

vim.keymap.set("n", "<C-n>", function()
    vim.cmd [[tabnew]]
end, { noremap = true, silent = true })
vim.keymap.set("n", "<Tab>", function()
    vim.cmd [[tabnext]]
end, { noremap = true, silent = true })
vim.keymap.set("n", "<S-Tab>", function()
    vim.cmd [[tabprev]]
end, { noremap = true, silent = true })


-- Go back/forward
vim.keymap.set("n", ")", vim.api.nvim_replace_termcodes("<C-i>", true, false, true), { noremap = true })
vim.keymap.set("n", "(", "<C-o>", { noremap = true })


-- LSP

local diagnostic_window = nil
local related_diagnostic_window = nil
local related_diagnostic_uri = nil

local latent_edit = nil

vim.keymap.set("n", "<CR>", function()
    if latent_edit then
        vim.cmd("edit " .. latent_edit)
        latent_edit = nil
        return
    end
    local url = vim.fn.expand("<cfile>")

    if url == "" then
        return
    elseif vim.fn.filereadable(url) == 1 then
        print("Press <CR> to edit '" .. url)
        local answer = vim.fn.getchar() == 13
        if answer then
            print("Navigate to the window you would like to edit in and press <CR> to edit in that window")
            latent_edit = url
        end
    else
        print("Press <CR> to open '" .. url .. "' in browser?")
        local answer = vim.fn.getchar() == 13
        if answer then
            vim.fn.jobstart({ "xdg-open", url }, { detatch = true })
        end
    end
end, { noremap = true, silent = true })

vim.keymap.set("n", ".", function()
    if diagnostic_window then
        vim.lsp.buf.code_action()
    else
        local _, win = vim.diagnostic.open_float({
            border = "rounded"
        })

        if not win then
            vim.lsp.buf.hover()
        end
        diagnostic_window = win

        local line = vim.api.nvim_win_get_cursor(0)[1] - 1
        local diags = vim.diagnostic.get(0, { lnum = line })

        local str_diags = {}
        local max_diag_len = 0
        related_diagnostic_uri = {}

        for _, d in ipairs(diags) do
            if d.user_data and d.user_data.lsp and d.user_data.lsp.relatedInformation then
                for _, ri in ipairs(d.user_data.lsp.relatedInformation) do
                    if string.find(string.lower(ri.message), "original", 1, true) then
                        local uri_info = {
                            uri = vim.uri_to_fname(ri.location.uri),
                            line = ri.location.range.start.line + 1,
                            column = ri.location.range.start.character
                        }
                        local diag = ri.message ..
                            ": '" ..
                            uri_info.uri ..
                            ':' .. uri_info.line ..
                            ':' .. uri_info.column .. "'"
                        str_diags[#str_diags + 1] = diag
                        if #diag > max_diag_len then
                            max_diag_len = #diag
                        end

                        related_diagnostic_uri[#related_diagnostic_uri + 1] = uri_info
                    end
                end
            end
        end

        if #str_diags == 0 then
            return
        end

        str_diags[#str_diags + 1] = "Press ',' to follow diagnostic(s)"

        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, str_diags)

        local win_height = diagnostic_window and vim.api.nvim_win_get_height(diagnostic_window) or nil
        if win_height == nil then
            return
        end

        local opts = {
            relative = "win",
            win = diagnostic_window,
            row = win_height,
            col = 0,
            anchor = "NW",
            width = max_diag_len,
            height = #str_diags,
            border = "rounded",
            title = "Related Diagnostics",
            style = "minimal",
        }

        related_diagnostic_window = vim.api.nvim_open_win(buf, false, opts)
    end
end, { noremap = true, silent = true })

vim.keymap.set("n", "<Esc>", function()
    if diagnostic_window then
        vim.schedule(function()
            if vim.api.nvim_win_is_valid(diagnostic_window) then
                vim.api.nvim_win_close(diagnostic_window, true)
            end
        end)
        return ""
    else
        local cmp = require("blink.cmp")
        if cmp.is_menu_visible() then
            cmp.hide()
            return ""
        end
    end
    return "<Esc>"
end, { noremap = true, silent = true, expr = true })

vim.api.nvim_create_autocmd("WinClosed", {
    callback = function(args)
        if tonumber(args.match) == diagnostic_window then
            diagnostic_window = nil
            if related_diagnostic_window ~= nil then
                vim.api.nvim_win_close(related_diagnostic_window, true)
                related_diagnostic_window = nil
                related_diagnostic_uri = nil
            end
        end
    end
})


-- Debugger

vim.keymap.set("n", "b", function()
    require("dap").toggle_breakpoint()
end, { noremap = true, silent = true })

vim.keymap.set("n", "c", function()
    require("nvimbugger").load_launch_and_debug()
end, { noremap = true, silent = true })

vim.keymap.set("n", "n", function()
    require("dap").step_over()
end, { noremap = true, silent = true })

vim.keymap.set("n", "i", function()
    require("dap").step_into()
end, { noremap = true, silent = true })


-- Git/terminal/other plugins
vim.keymap.set("n", "gg", function() vim.cmd("LazyGit") end, { noremap = true, silent = true })
vim.keymap.set("n", "g", function() vim.cmd("LazyGit") end, { noremap = true, silent = true })

vim.keymap.set("n", "l", function()
    vim.cmd("Lazy")
end, { noremap = true, silent = true })

vim.keymap.set({ "t", "n" }, "`", function() vim.cmd [[ToggleTerm]] end, { noremap = true, silent = true })
vim.keymap.set("t", "<C-e>", "<C-\\><C-n>", { noremap = true, silent = true })

vim.keymap.set("n", "h", function() require("hex").toggle() end, { noremap = true, silent = true })


-- File Browser

function ON_ATTACH_NVIM_TREE(bufnr)
    local api = require("nvim-tree.api")
    local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    vim.api.nvim_create_autocmd("BufEnter", {
        buffer = bufnr,
        callback = function()
            vim.cmd [[NvimTreeRefresh]]
        end
    })

    vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open selection"))
    vim.keymap.set("n", "o", api.node.open.vertical, opts("Open selection in a new vertical window"))
    vim.keymap.set("n", "ov", api.node.open.vertical, opts("Open selection in a new vertical window"))
    vim.keymap.set("n", "oh", api.node.open.horizontal, opts("Open selection in a new vertical window"))
    vim.keymap.set("n", "<BS>", api.tree.change_root_to_node, opts("Open selection"))

    vim.keymap.set("n", "n", api.fs.create, opts("Create file/directory"))

    vim.keymap.set("n", "<Del>", api.fs.trash, opts("Move selection to trash"))
    vim.keymap.set("n", "<S-Del>", api.fs.remove, opts("Permanently delete selection"))

    vim.keymap.set("n", "f", function()
        vim.cmd("Telescope find_files")
    end, opts("Find files"))

    vim.keymap.set("n", "c", api.fs.copy.node, opts("Copy selection"))
    vim.keymap.set("n", "x", api.fs.cut, opts("Cut selection"))
    vim.keymap.set("n", "v", api.fs.paste, opts("Paste copy/cut buffer"))

    vim.keymap.set("n", "r", api.fs.rename, opts("Rename selection"))
    vim.keymap.set("n", "R", function() vim.cmd [[NvimTreeRefresh]] end, opts("Refresh"))

    vim.keymap.set("n", "t", function() vim.cmd [[NvimTreeToggle]] end)
end

vim.keymap.set("n", "t", function() vim.cmd [[NvimTreeToggle]] end)


-- Keymaps that require the lsp buffer

function ON_ATTACH(client, buffnr)
    local opts = { buffer = buffnr, silent = true, noremap = true }
    local telescope = require("telescope.builtin")

    if client.supports_method("textDocument/formatting") then
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = buffnr,
            callback = function()
                vim.lsp.buf.format({
                    bufnr = buffnr,
                    formatting_options = {
                        insertFinalNewline = true,
                        trimFinalNewlines = true,
                        trimTrailingWhitespace = true,
                    },
                })
            end,
        })
    end

    vim.keymap.set("n", ";", vim.lsp.buf.declaration)
    vim.keymap.set("n", "'", vim.lsp.buf.definition)

    vim.keymap.set("n", ",", function()
        if related_diagnostic_uri then
            if #related_diagnostic_uri == 1 then
                vim.cmd("e " .. related_diagnostic_uri[1].uri)
                vim.api.nvim_win_set_cursor(0, { related_diagnostic_uri[1].line, related_diagnostic_uri[1].column })
            elseif #related_diagnostic_uri ~= 0 then
                local uris = {}
                for i, uri in ipairs(related_diagnostic_uri) do
                    uris[i] = uri.uri .. ":" .. uri.line .. ":" .. uri.column
                end
                vim.ui.select(
                    uris,
                    {
                        prompt = "Which diagnostic would you like to follow",
                        kind = "number",
                    },
                    function(_, i)
                        vim.cmd("e " .. related_diagnostic_uri[i].uri)
                        vim.api.nvim_win_set_cursor(0, {
                            related_diagnostic_uri[i].line,
                            related_diagnostic_uri[i].column
                        })
                    end
                )
            end
        else
            telescope.lsp_references({
                include_current_line = true,
                fname_width = 50,
            })
        end
    end, opts)
    vim.keymap.set("n", "<F2>", function()
        -- local new_name = vim.fn.input({ prompt = "New name: ", text = vim.fn.expand("<cword>") })
        vim.lsp.buf.rename()
    end, opts)
end

-- Telescope

vim.keymap.set("n", '"', function()
    local word = vim.fn.expand("<cword>")
    if word == "" then
        return
    end

    -- Very nomagic, word boundaries, escaped
    local pattern = "\\V\\<" .. vim.fn.escape(word, "\\") .. "\\>"

    -- Set search register and enable hlsearch
    vim.fn.setreg("/", pattern)
    vim.o.hlsearch = true
end, { silent = true })

vim.keymap.set("n", "f", function()
    vim.cmd("Telescope current_buffer_fuzzy_find")
end, { noremap = true, silent = true, desc = "Search in current file" })
vim.keymap.set("n", "<C-f>", function()
    vim.cmd("Telescope live_grep")
end, { noremap = true, silent = true, desc = "Search text in project" })
vim.keymap.set("n", "<S-f>", function()
    vim.cmd("Telescope find_files")
end, { noremap = true, silent = true, desc = "Search files in cwd" })

local function custom_dir_live_grep()
    local folder = vim.fn.input({
        prompt = "Input a subdirectory to search: ",
        completion = "dir",
    })
    if folder == nil or folder == "" then
        return
    end
    require("telescope.builtin").live_grep({
        cwd = folder
    })
end

vim.keymap.set("n", "<C-f><C-f>", custom_dir_live_grep, { noremap = true, silent = true })
vim.keymap.set("n", "<C-f>f", custom_dir_live_grep, { noremap = true, silent = true })


-- Projects

--vim.keymap.set("n", "o", function ()
--    require("projects").show_recent()
--end)
