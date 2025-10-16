-- SETTINGS

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.number = true


-- KEYMAP

-- Enter insert mode
vim.keymap.set("n", "e", "i", { noremap = true, silent = true })

-- Block select
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

local move10 = {
    ["<S-Up>"] = "10k",
    ["<S-Down>"] = "10j",
    ["<S-Left>"] = "10h",
    ["<S-Right>"] = "10l",
}

for key, cmd in pairs(move10) do
    vim.keymap.set("n", key, cmd, { noremap = true, silent = true })

    vim.keymap.set("i", key, "<C-o>" .. cmd, { noremap = true, silent = true })
end

