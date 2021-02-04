local function stripHeaders()

end

local function checkIfRequestNeedsAuth(config)

end

function Access:start(config)
    -- Main business logic for this plugin
    -- Returns: nothing

    -- Init
    kong.log.debug("[access.lua] : Starting Nx Kong Pre Auth Hook...")

    -- Strip headers for safety, to prevent spoofing.
    stripHeaders()

    -- Checks if conditions are met for auth
    local doesNeedAuth = checkIfRequestNeedsAuth(config)
end

return Access