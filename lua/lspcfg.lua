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

            if not vim.loop.fs_stat(scratchdir .. "/lsp/" .. name .. ".lua") then
                print("LSP '" .. name .. "' not found. Searched:\n'" .. lsp_dir .. "'\n'" .. lspadv .. "'\n")
                return
            end

            vim.fn.system({
                "cp", scratchdir .. "/lsp/" .. name .. ".lua", lspadv
            })
        end
        local config = require("lspadv." .. name)
        config.on_attach = ON_ATTACH
        vim.lsp.config(name, config)
    else
        if not vim.loop.fs_stat(scratchdir .. "/lsp/" .. name .. ".lua") then
            print("LSP '" .. name .. "' not found. Searched:\n'" .. lsp_dir .. "'\n'" .. lspadv .. "'\n")
            return
        end

        local config = require("lsp." .. name)
        config.on_attach = ON_ATTACH
        vim.lsp.config(name, config)
    end

    vim.lsp.enable(name)
end


addlsp("lua_ls", true)
addlsp("rust_analyzer")
addlsp("clangd")
addlsp("bashls", false)

vim.lsp.handlers["textDocument/semanticTokens/full"] = vim.lsp.semantic_tokens.on_full
vim.lsp.handlers["textDocument/semanticTokens/range"] = vim.lsp.semantic_tokens.on_range


-- Debugger

function SEARCH_DEBUG_CFG()
    local dap = require("dap")

    local session = dap.session()

    if session then
        dap.continue()
        return
    end

    local cwd = vim.fn.getcwd()
    local path = cwd .. "/.nvim/launch.json"

    local ok, content = pcall(vim.fn.readfile, path)
    if not ok then
        print("Failed to read '" .. path .. "'")
        return
    end
    content = table.concat(content, "\n")

    local ok2, launch = pcall(vim.fn.json_decode, content)
    if not ok2 then
        print("Failed to parse json:\n\n" .. content)
        return
    end

    for lang, configs in pairs(launch) do
        local type = dap.adapters.languages[lang]
        local defaults = {
            { "type",    type },
            { "request", "launch" },
            { "args",    {} },
            { "cwd",     cwd },
        }

        for i, config in ipairs(configs) do
            for _, default in ipairs(defaults) do configs[i][default[1]] = config[default[1]] or default[2] end
        end

        dap.configurations[lang] = configs
    end

    vim.inspect(dap.run(dap.configurations.rust[1]))
end
