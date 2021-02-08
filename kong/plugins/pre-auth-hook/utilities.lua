local set_header = kong.service.request.set_header
local clear_header = kong.service.request.clear_header
local constants = require("kong.constants")


local Utilities = {
    config = nil,
}

local function setConsumer(consumer, credential)
    kong.client.authenticate(consumer, credential)

    if consumer and consumer.id then
        set_header(constants.HEADERS.CONSUMER_ID, consumer.id)
    else
        clear_header(constants.HEADERS.CONSUMER_ID)
    end

    if consumer and consumer.custom_id then
        set_header(constants.HEADERS.CONSUMER_CUSTOM_ID, consumer.custom_id)
    else
        clear_header(constants.HEADERS.CONSUMER_CUSTOM_ID)
    end

    if consumer and consumer.username then
        set_header(constants.HEADERS.CONSUMER_USERNAME, consumer.username)
    else
        clear_header(constants.HEADERS.CONSUMER_USERNAME)
    end

    if credential and credential.client_id then
        set_header(constants.HEADERS.CREDENTIAL_IDENTIFIER, credential.client_id)
    else
        clear_header(constants.HEADERS.CREDENTIAL_IDENTIFIER)
    end

    clear_header(constants.HEADERS.CREDENTIAL_USERNAME)

    if credential then
        clear_header(constants.HEADERS.ANONYMOUS)
    else
        set_header(constants.HEADERS.ANONYMOUS, true)
    end
end

function Utilities:new(config)
    -- Constructor
    -- :param config: The plugin config
    self.config = config
    return Utilities
end

function Utilities:skipAuth()
    -- Sets headers to indicate to subsequent plugins that auth is not required for this request
    -- Returns: nothing

    -- Set the special header to indicate to the post-auth-hook plugin that no auth is required
    kong.log.debug("[utilities.lua] : Setting X-Skip-Kong-Auth header")
    set_header('X-Skip-Kong-Auth', true)

    -- Get the anonymous consumer from the config and set it in the relevant headers
    if self.config.anonymous then
        kong.log.debug("[utilities.lua] : Anonymous consumer specified in config. Checking cache for consumer...")
        local consumer_cache_key = kong.db.consumers:cache_key(self.config.anonymous)
        local consumer, err = kong.cache:get(consumer_cache_key, nil,
                kong.client.load_consumer,
                self.config.anonymous, true)
        if err then
            kong.log.err("[utilities.lua] : Error in fetching consumer" .. err)
            return kong.response.error(err.status, err.message, err.headers)
        end
        kong.log.debug("[utilities.lua] : Consumer found, setting headers...")
        setConsumer(consumer)
    else
        kong.log.err("[utilities.lua] : Could not process in skipAuth: " .. err.message)
        return kong.response.error(err.status, err.message, err.headers)
    end
end

return Utilities