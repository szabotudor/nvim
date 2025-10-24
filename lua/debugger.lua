function READ_JSON(path)
    local fd = vim.loop.fs_open(path, "r", 438)
    if not fd then return nil end
    local stat = vim.loop.fs_fstat(fd)
    local data = vim.loop.fs_read(fd, stat.size, 0)
    vim.loop.fs_close(fd)
    return vim.fn.json_decode(data)
end

function DAP_LAUNCH(dap)
    local client = vim.lsp.get_clients({ bufnr = 0 })[1]
    if not client then
        print("No lsp client detected for current buffer\n")
        return
    end

    local language = languages[client.name]
    if not language then
        print("Unrecognized lsp client " .. client.name .. "\n")
        return
    end

    local configs = dap.configurations[language]
    if not configs then
        print("Language " .. language " not supported by debugger\n")
        return
    end

    vim.ui.select(
        configs,
        {
            prompt = "Choose a configuration to run: ",
            format_item = function(item)
                return item.name
            end
        },
        function(item, i)
            if not item or not i then
                print("Invalid choice\n")
                return
            end
            dap.run(item)
        end
    )
end

function SEARCH_DEBUG_CFG()
    local dap = require("dap")

    local session = dap.session()

    if session then
        dap.continue()
        return
    end

    local cwd = vim.fn.getcwd()
    local path = cwd .. "/.nvim/launch.json"

    local launch = READ_JSON(path)
    if not launch then
        print("Couldn't read '.nvim/launch.json' in project directory\n")
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

    DAP_LAUNCH(dap)
end
