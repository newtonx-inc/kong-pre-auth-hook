-- Extending the Base Plugin handler is optional, as there is no real
-- concept of interface in Lua, but the Base Plugin handler's methods
-- can be called from your child implementation and will print logs
-- in your `error.log` file (where all logs are printed).
local BasePlugin = require "kong.plugins.base_plugin"

local PreAuthHookHandler = BasePlugin:extend()

PreAuthHookHandler.VERSION = "0.2.0"
PreAuthHookHandler.PRIORITY = 1100 -- Execute before all Kong auth plugins


-- Your plugin handler's constructor. If you are extending the
-- Base Plugin handler, it's only role is to instantiate itself
-- with a name. The name is your plugin name as it will be printed in the logs.
function PreAuthHookHandler:new()
    PreAuthHookHandler.super.new(self, "nx-kong-pre-auth-hook")
end

function PreAuthHookHandler:init_worker()
    -- Eventually, execute the parent implementation
    -- (will log that your plugin is entering this context)
    PreAuthHookHandler.super.init_worker(self)

    -- Implement any custom logic here
    -- TODO

end

function PreAuthHookHandler:access(config)
    -- Eventually, execute the parent implementation
    -- (will log that your plugin is entering this context)
    PreAuthHookHandler.super.access(self)
    -- Implement any custom logic here

end


-- This module needs to return the created table, so that Kong
-- can execute those functions.
return PreAuthHookHandler