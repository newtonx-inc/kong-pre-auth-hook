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

function Filters:checkMatchingHttpMethod(methods)
    -- Checks whether the current request is a match for one of the given methods.
    -- :param methods: Methods to check against
    -- If *methods* is nil, false is automatically returned
    -- Returns: bool

    kong.log.debug("[filters.lua] : Checking HTTP methods for a match")

    if not methods then
        return false
    end

    return matchExists(kong.request.get_method(), methods)
end

function Filters:checkMatchingPaths(paths)
    -- Checks whether the current request is a match for one of the given paths.
    -- :param paths: Paths to check against
    -- If *paths* is nil, false is automatically returned
    -- Returns: bool

    local currentPath = kong.request.get_path()
    kong.log.debug("[filters.lua] : Checking paths for a match to: " .. currentPath)

    for _, path in ipairs(paths or {}) do
        local match = string.find(currentPath, "^" .. path)
        if match then
            return true
        end
    end

    return false
end

function Filters:checkMatchingHosts(hosts)
    -- Checks whether the current request is a match for one of the given hosts.
    -- :param hosts: Hosts to check against
    -- If *hosts* is nil, false is automatically returned
    -- Returns: bool

    kong.log.debug("[filters.lua] : Checking hosts for a match")

    if not hosts then
        return false
    end

    return matchExists(kong.request.get_host(), hosts)
end

function Filters:checkMatchingHeaders(headers)
    -- Checks whether the current request is a match for one of the given headers.
    -- :param headers: Headers to check against
    -- If *headers* is nil, false is automatically returned
    -- Returns: bool

    kong.log.debug("[filters.lua] : Checking header names for a match")

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
    -- Checks all match conditions in the plugin config to determine whether the given request matches any of the conditions
    -- Returns: bool

    -- If no routes, return false
    -- Otherwise, iterate through routes to see if any matches exist
    for _, route in ipairs(self.config.match_routes or {}) do
        local res = self:checkMatchingHosts({route.host}) and self:checkMatchingPaths(route.paths) and self:checkMatchingHttpMethod(route.methods) and self:checkMatchingHeaders({route.headers})
        if res then
            return true
        end
    end
    return false
end

return Filters