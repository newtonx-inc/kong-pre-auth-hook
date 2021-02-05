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
                    {
                        -- HTTP Methods to require authentication on
                        match_methods = {
                            type = "array",
                            required = false,
                            elements = typedefs.http_method,
                        },
                    },
                    {
                        -- Paths to require authentication on
                        match_paths = typedefs.paths,
                    },
                    {
                        -- Hosts to require authentication on
                        match_hosts = typedefs.hosts,
                    },
                    {
                        -- Headers to require authentication on
                        match_headers = {
                            type = "array",
                            required = false,
                            elements = {
                                type = "string",
                            },
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