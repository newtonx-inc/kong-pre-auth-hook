local typedefs = require('kong.db.schema.typedefs')

return {
    name = 'kong-pre-auth-hook',
    fields = {
        {
            protocols = typedefs.protocols_http
        },
        {

            config = {
                type = 'record',
                fields = {
                    -- Describe your plugin's configuration's schema here.
                    {
                        -- Additional headers to strip out
                        strip_headers = {
                            type = "array",
                            required = false,
                            elements = {
                                type = "string"
                            },
                            default = {},
                        },
                    },
                    -- Routes to enforce authentication on
                    {
                        match_routes = {
                            type = "array",
                            required = false,
                            {
                              type = "map",
                              keys = "string",
                              values = {
                                type = "array",
                                elements = {
                                  type = "string",
                                },
                              },
                            },
                            default = {},
                        },
                    },
                    {
                      -- The id of an anonymous consumer
                      anonymous = {
                          type = "string",
                          required = false,
                      },
                    },
                },
            },
        },
    },
}