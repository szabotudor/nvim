-- SETTINGS

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.number = true


-- KEYMAP

-- Deleting
vim.keymap.set({ "n", "v" }, "<S-d>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<Del>", "d", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<S-Del>", "dd", { noremap = true, silent = true })

-- Enter insert mode
vim.keymap.set("n", "<S-a>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "i", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "e", "i", { noremap = true, silent = true })
vim.keymap.set("n", "<S-e>", "a", { noremap = true, silent = true })
vim.keymap.set("n", "<C-e>", "<S-a>", { noremap = true, silent = true })

-- Block select
vim.keymap.set("n", "<S-v>", "Nop")
vim.keymap.set("n", "v", "Nop")
vim.keymap.set("n", "b", "v", { noremap = true, silent = true })
vim.keymap.set("n", "<S-b>", "<S-v>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-b>", "<C-v>", { noremap = true, silent = true })

-- Undo/redo
vim.keymap.set({ "n", "i" }, "<C-z>", function() vim.cmd("undo") end, { noremap = true, silent = true })
vim.keymap.set({ "n", "i" }, "<C-y>", function() vim.cmd("redo") end, { noremap = true, silent = true })
vim.keymap.set({ "n", "i" }, "<C-r>", function() vim.cmd("redo") end, { noremap = true, silent = true })

-- Copy/cut in normal and visual mode
vim.keymap.set({ "n", "v" }, "<C-c>", '"+y', { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<C-x>", '"+d', { noremap = true, silent = true })

-- Paste in insert mode
vim.keymap.set({ "i" }, "<C-v>", function()
    vim.api.nvim_put({ vim.fn.getreg('+') }, 'c', true, true)
    print("Hello World!")
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


-- Saving

vim.keymap.set({ "n", "v", "i" }, "<C-s>", function()
    vim.cmd("write")
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

function resize_window(dir, delta)
    local win = vim.api.nvim_get_current_win()

    if dir == "u" then
        vim.api.nvim_win_set_height(win, vim.api.nvim_win_get_height(win) + delta)
    elseif dir == "d" then
        vim.api.nvim_win_set_height(win, vim.api.nvim_win_get_height(win) - delta)
    elseif dir == "l" then
        vim.api.nvim_win_set_width(win, vim.api.nvim_win_get_width(win) - delta)
    elseif dir == "r" then
        vim.api.nvim_win_set_width(win, vim.api.nvim_win_get_width(win) + delta)
    end
end

vim.keymap.set("n", "<C-w>w", function ()
    resize_window("u", 3)
end, { noremap = true, silent = true })
vim.keymap.set("n", "<C-w>s", function ()
    resize_window("d", 3)
end, { noremap = true, silent = true })
vim.keymap.set("n", "<C-w>a", function ()
    resize_window("l", 3)
end, { noremap = true, silent = true })
vim.keymap.set("n", "<C-w>d", function ()
    resize_window("r", 3)
end, { noremap = true, silent = true })


-- Git
vim.keymap.set("n", "<C-g>", function ()
    vim.cmd("LazyGit")
end, { noremap = true, silent = true })

