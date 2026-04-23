local DEFAULT_CONFIG = {
    format = {
        tab = {
            use_spaces = true,
            size = 4,
        },
        auto_format = true,
    }
}

-- Read configuration from file
function ConfigRead()
    local config_dir = vim.fn.getcwd() .. "/.nvim"
    local config_file = config_dir .. "/settings.json"

    -- Ensure directory exists
    vim.fn.mkdir(config_dir, "p")

    -- Start with defaults
    local config = vim.deepcopy(DEFAULT_CONFIG)

    -- Load user config if it exists
    if vim.fn.filereadable(config_file) == 1 then
        local file = io.open(config_file, "r")
        if file then
            local content = file:read("*all")
            file:close()

            local ok, user_config = pcall(vim.json.decode, content)
            if ok and type(user_config) == "table" then
                -- Merge user config with defaults
                for k, v in pairs(user_config) do
                    config[k] = v
                end
            else
                vim.notify("Error parsing config file: " .. config_file, vim.log.levels.ERROR)
            end
        end
    else
        -- Create default config file
        ConfigWrite(config)
    end

    return config
end

-- Write configuration to file
function ConfigWrite(config)
    local config_dir = vim.fn.getcwd() .. "/.nvim"
    local config_file = config_dir .. "/settings.json"

    -- Ensure directory exists
    vim.fn.mkdir(config_dir, "p")

    local file = io.open(config_file, "w")
    if not file then
        vim.notify("Failed to write config file: " .. config_file, vim.log.levels.ERROR)
        return false
    end

    -- Serialize to JSON with pretty printing
    local json_content = vim.json.encode(config, { indent = config.format.tab.use_spaces and "    " or "        " })

    -- Pretty print manually (vim.json.encode doesn't have pretty option)
    -- local pretty_json = json_content:gsub(",", ",\n  "):gsub("{", "{\n  "):gsub("}", "\n}")

    file:write(json_content)
    file:write("\n")
    file:close()
    return true
end

-- Ensure config exists
local _ = ConfigRead()
