function READ_JSON(path)
    local fd = vim.loop.fs_open(path, "r", 438)
    if not fd then return nil end
    local stat = vim.loop.fs_fstat(fd)
    local data = vim.loop.fs_read(fd, stat.size, 0)
    vim.loop.fs_close(fd)
    return vim.fn.json_decode(data)
end

-- Copied from DAP cause they hid this away for some reason
local dap_tools = {}

function dap_tools.eval_option(option)
    if type(option) == 'function' then
        option = option()
    end
    if type(option) == "thread" then
        assert(coroutine.status(option) == "suspended", "If option is a thread it must be suspended")
        local co = coroutine.running()
        -- Schedule ensures `coroutine.resume` happens _after_ coroutine.yield
        -- This is necessary in case the option coroutine is synchronous and
        -- gives back control immediately
        vim.schedule(function()
            coroutine.resume(option, co)
        end)
        option = coroutine.yield()
    end
    return option
end

dap_tools.var_placeholders = {
    ['${file}'] = function(_)
        return vim.fn.expand("%:p")
    end,
    ['${fileBasename}'] = function(_)
        return vim.fn.expand("%:t")
    end,
    ['${fileBasenameNoExtension}'] = function(_)
        return vim.fn.fnamemodify(vim.fn.expand("%:t"), ":r")
    end,
    ['${fileDirname}'] = function(_)
        return vim.fn.expand("%:p:h")
    end,
    ['${fileExtname}'] = function(_)
        return vim.fn.expand("%:e")
    end,
    ['${relativeFile}'] = function(_)
        return vim.fn.expand("%:.")
    end,
    ['${relativeFileDirname}'] = function(_)
        return vim.fn.fnamemodify(vim.fn.expand("%:.:h"), ":r")
    end,
    ['${workspaceFolder}'] = function(_)
        return vim.fn.getcwd()
    end,
    ['${workspaceFolderBasename}'] = function(_)
        return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    end,
    ['${env:([%w_]+)}'] = function(match)
        return os.getenv(match) or ''
    end,
}


function dap_tools.expand_config_variables(option)
    option = dap_tools.eval_option(option)
    if option == nil then
        return option
    end
    if type(option) == "table" then
        local mt = getmetatable(option)
        local result = {}
        for k, v in pairs(option) do
            result[dap_tools.expand_config_variables(k)] = dap_tools.expand_config_variables(v)
        end
        return setmetatable(result, mt)
    end
    if type(option) ~= "string" then
        return option
    end
    local ret = option
    for key, fn in pairs(dap_tools.var_placeholders) do
        ret = ret:gsub(key, fn)
    end
    return ret
end

-- why

function DO_DAP_RUN(dap, config)
    local util = require("dap.utils")

    local cur_win = vim.api.nvim_get_current_win()
    dap.defaults.fallback.switchbuf = function(bufnr, line, column)
        vim.api.nvim_win_set_buf(cur_win, bufnr)
        vim.api.nvim_win_set_cursor(cur_win, { line, column })
    end
    dap.set_log_level("DEBUG")
    local term = require("toggleterm.terminal").Terminal:new({
        cmd = "bash -c \"gdbserver :1234 " ..
            dap_tools.expand_config_variables(config.program) ..
            "; exec bash\"",
        direction = "horizontal",
        on_create = function(_)
            dap.run(config)
        end,
        on_stdout = function(t, job, data, name)
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
            DO_DAP_RUN(dap, item)
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
            { "type",        type },
            { "request",     "attach" },
            { "args",        {} },
            { "cwd",         cwd },
            { "target",      "localhost:1234" },
            { "stopAtEntry", false },
        }

        for i, config in ipairs(configs) do
            for _, default in ipairs(defaults) do configs[i][default[1]] = config[default[1]] or default[2] end
        end

        dap.configurations[lang] = configs
    end

    DAP_LAUNCH(dap)
end
