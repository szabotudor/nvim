local P = {}

-- Copied from DAP cause they hid this away for some reason

function P.eval_option(option)
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

P.var_placeholders = {
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


function P.expand_config_variables(option)
    option = P.eval_option(option)
    if option == nil then
        return option
    end
    if type(option) == "table" then
        local mt = getmetatable(option)
        local result = {}
        for k, v in pairs(option) do
            result[P.expand_config_variables(k)] = P.expand_config_variables(v)
        end
        return setmetatable(result, mt)
    end
    if type(option) ~= "string" then
        return option
    end
    local ret = option
    for key, fn in pairs(P.var_placeholders) do
        ret = ret:gsub(key, fn)
    end
    return ret
end

-- why

return P
