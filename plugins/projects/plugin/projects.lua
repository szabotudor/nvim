local cache_dir = vim.fn.stdpath("cache") .. "/projects"
local out = vim.fn.system({
    "mkdir", "-p", cache_dir
})

