local Filters = {
    config = nil,
}

local function matchExists(obj, list)
    -- Checks to see if the given object is a member of the list provided
    -- Returns: bool
    for _, item in ipairs(list) do
        if item == obj then
            return true
        end
    end
    return false
end

function Filters:checkMatchingHttpMethod()
    -- Checks whether the current request is a match for one of the given methods.
    -- If *methods* is nil, false is automatically returned
    -- Returns: bool

    kong.log.debug("[filters.lua] : Checking HTTP methods for a match")

    local methods = self.config.match_methods

    if not methods then
        return false
    end

    return matchExists(kong.request.get_method(), methods)
end

function Filters:checkMatchingPaths()
    -- Checks whether the current request is a match for one of the given paths.
    -- If *paths* is nil, false is automatically returned
    -- Returns: bool

    local currentPath = kong.request.get_path()
    kong.log.debug("[filters.lua] : Checking paths for a match to: " .. currentPath)

    for _, path in ipairs(self.config.match_paths or {}) do
        local match = string.find(currentPath, "^" .. path)
        if match then
            return true
        end
    end

    return false
end

function Filters:checkMatchingHosts()
    -- Checks whether the current request is a match for one of the given hosts.
    -- If *hosts* is nil, false is automatically returned
    -- Returns: bool

    kong.log.debug("[filters.lua] : Checking hosts for a match")

    local hosts = self.config.match_hosts

    if not hosts then
        return false
    end

    return matchExists(kong.request.get_host(), hosts)
end

function Filters:checkMatchingHeaders()
    -- Checks whether the current request is a match for one of the given headers.
    -- If *headers* is nil, false is automatically returned
    -- Returns: bool

    kong.log.debug("[filters.lua] : Checking header names for a match")

    local headers = self.config.match_headers

    if not headers then
        return false
    end

    for _, headerKey in ipairs(headers) do
        local headerVal = kong.request.get_header(headerKey)
        if headerVal then
            return true
        end
    end

    return false
end

function Filters:new(config)
    -- Constructor
    -- :param config: The plugin's config object
    self.config = config
    return Filters
end

function Filters:checkMatchingAll()
    -- Checks all match-* conditions in the plugin config to determine whether the given request matches any of the conditions
    -- Returns: bool
    return self:checkMatchingHeaders() or self:checkMatchingHosts() or self:checkMatchingHttpMethod() or self:checkMatchingPaths()
end

return Filters