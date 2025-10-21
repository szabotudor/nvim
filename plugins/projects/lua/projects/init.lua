local P = {}

function P.setup(_)
    -- Empty
end

function P.show_recent()
    local recent = vim.fn.stdpath('cache') .. "/projects/recent.json"

    if not vim.loop.fs_stat(recent) then
        local projects = io.open(recent, 'r')
        if projects == nil then
            projects = assert(io.open(recent, 'w+'))
            projects:write('[]')
        end
    end

    local projects_file = assert(io.open(recent, 'r'), "Error opening recent projects list\n" .. recent)
    local projects = projects_file:read("*a")

    local win = require("windowmaker").window("Hello World", { x = 10, y = 20 })
end

return P

