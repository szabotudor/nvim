local scratchdir = vim.fn.stdpath("data") .. "/lspconfig"

if not (vim.loop or vim.uv).fs_stat(scratchdir) then
    local repo = "https://github.com/neovim/nvim-lspconfig.git"
    local out = vim.fn.system({
        "git", "clone", "--filter=blob:none", repo, scratchdir
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lspconfig repo\n" },
            { out },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(-1)
    end
end

local lsp_dir = vim.fn.stdpath("data") .. "/lspconfig/?.lua"
package.path = lsp_dir .. ";" .. package.path

local function addlsp(name, allow_manual_cfg)
    local lspadv = vim.fn.stdpath("config") .. "/lua/lspadv"

    if allow_manual_cfg then
        if not vim.loop.fs_stat(lspadv .. "/" .. name .. ".lua") then
            vim.fn.system({
                "mkdir", "-p", lspadv
            })

            vim.fn.system({
                "cp", scratchdir .. "/lsp/" .. name .. ".lua", lspadv
            })
        end
        local config = require("lspadv." .. name)
        config.on_attach = ON_ATTACH
        vim.lsp.config(name, config)
    else
        local config = require("lsp." .. name)
        config.on_attach = ON_ATTACH
        vim.lsp.config(name, config)
    end

    vim.lsp.enable(name)
end


addlsp("lua_ls", true)
addlsp("rust_analyzer")
addlsp("clangd")

