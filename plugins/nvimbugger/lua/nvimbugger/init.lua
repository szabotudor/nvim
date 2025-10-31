local P = {}

P.dap_tools = require("nvimbugger.dap_tools")

local function read_json(path)
    local fd = vim.loop.fs_open(path, "r", 438)
    if not fd then return nil end
    local stat = vim.loop.fs_fstat(fd)
    local data = vim.loop.fs_read(fd, stat.size, 0)
    vim.loop.fs_close(fd)
    return vim.fn.json_decode(data)
end

function P.do_dap_run(dap, config)
    local cur_win = vim.api.nvim_get_current_win()
    dap.defaults.fallback.switchbuf = function(bufnr, line, column)
        vim.api.nvim_win_set_buf(cur_win, bufnr)
        vim.api.nvim_win_set_cursor(cur_win, { line, column })
    end
    dap.set_log_level("DEBUG")
    local term = require("toggleterm.terminal").Terminal:new({
        cmd = "bash -c \"gdbserver :1234 " ..
            P.dap_tools.expand_config_variables(config.program) ..
            "; exec bash\"",
        direction = "horizontal",
        on_create = function(_)
            print("Running config: " .. vim.inspect(config) .. "\n")
            config.env = vim.fn.environ()
            dap.run(config)
        end,
        on_stdout = function(t, _, data, _)
            for _, s in ipairs(data) do
                if s:match("host") then
                    vim.defer_fn(function()
                        dap.continue()
                    end, 100)
                    t.on_stdout = nil
                    return
                end
            end
        end,
        on_exit = function(_)
            local session = dap.session()
            if session then
                dap.close()
                dap.listeners.after.event_output["wait_for_remote"] = nil
            end
        end,
    })
    term:toggle()
end

function P.dap_launch(dap)
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
            P.do_dap_run(dap, item)
        end
    )
end

function P.load_launch_and_debug()
    local dap = require("dap")

    local session = dap.session()

    if session then
        dap.continue()
        return
    end

    local cwd = vim.fn.getcwd()
    local path = cwd .. "/.nvim/launch.json"

    local launch = read_json(path)
    if not launch then
        print("Couldn't read '.nvim/launch.json' in project directory\n")
        return
    end

    for lang, configs in pairs(launch) do
        for _, config in ipairs(configs) do
            for k, default in pairs(P.languages[lang].defaults) do
                config[k] = config[k] or default
            end
        end

        dap.configurations[lang] = configs
    end

    P.dap_launch(dap)
end

function P.setup(opts)
    local dap = require("dap")
    P.languages = {}

    for lang, config in pairs(opts) do
        P.languages[lang] = {
            adapter = config.adapter.name,
            defaults = config.defaults,
        }
        dap.adapters[config.adapter.name] = config.adapter

        P.languages[lang].defaults = config.defaults
    end
end

return P
