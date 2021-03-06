# Kong PreAuth Hook
A Kong plugin for performing configurable operations before auth plugins run

**kong-pre-auth-hook** performs a few customizable operations before auth plugins run, such as stripping auth headers
that can be spoofed by requesters, and allowing for more finer grained control of whether auth plugins should run
or not based on the request. This plugin works in conjunction with [kong-post-auth-hook](https://github.com/newtonx-inc/kong-post-auth-hook)

# What this plugin does
## Strips headers that can be spoofed
Certain upstream headers that Kong auth plugins generate (e.g. `X-Consumer-ID`) can be spoofed by the original 
requester if not careful. This plugin clears all headers below in the upstream request, so that you can be sure that 
only plugins within your Kong setup would ever write those headers. You may also specify additional headers to clear.

### Headers stripped by default
* `X-Consumer-ID`
* `X-Consumer-Custom-ID`
* `X-Consumer-Username`
* `X-Credential-Identifier`
* `X-Anonymous-Consumer`
* `X-Userinfo` (used by kong-oidc-google-groups plugin)
* `X-Auth-Mechanism` (used by kong-post-auth-hook plugin, optionally)
* `X-Skip-Kong-Auth` (used by kong-post-auth-hook plugin)

## Decides whether authentication is needed
Sometimes you may want to have finer grained control as to whether or not a Kong auth plugin runs for a given request. Using
KongIngress or applying ingress rules is nice, but is rather limited, especially if you have more complex rules when 
you apply auth plugins at the Kubernetes Service level. Here are a few dimensions for which you can control whether 
auth plugins need to be applied or not: 

* HTTP Method
* Path
* Host
* Headers

# Installation

```bash
luarocks install kong-pre-auth-hook
```

Make sure you set your `KONG_PLUGINS` environment variable such that it reflects this plugin:

```bash
export KONG_PLUGINS=bundled,pre-auth-hook
```

# Requirements
* Kong auth plugins to be used in conjunction (e.g. oauth2, key-auth, jwt, etc.). All must be configured in 
["Logical OR"](https://docs.konghq.com/gateway-oss/2.2.x/auth/) mode.
* [Kong Post Auth Hook plugin](https://github.com/newtonx-inc/kong-post-auth-hook) 

# Dependencies (3rd party libs)
None

# Configuration

| Parameter     | Default | Required? | Description                                                                                                         |
|---------------|---------|-----------|---------------------------------------------------------------------------------------------------------------------|
| strip_headers | {}      | No        | Additional headers to strip out before the upstream request                                                         |
| match_routes  | {}      | No        | Routes to match on. This includes the host, paths, and methods                                                      |
| anonymous     |         | No        | Consumer ID to use as an "anonymous" consumer if auth fails. Used for "logical OR" in Kong multiple authentication. |

## Examples

```yaml
#...
config:
  match_routes: 
    - hosts: 
        - foo.mydomain.com
      paths: 
        - /protected
      methods: 
        - GET
        - POST
      headers:
        - X-Special-Header 
#...
```

## Details
### Paths
* Any valid LUA regex will do here. NOTE: The starting character (`^`) is implied here. E.g. `/.+/api/v1` translates
to `^/.+/api/v1`, such that a path of /rest/namespace/api/v1/hello would match.
* Note that the path evaluated contains the full path, before konghq.com/strip-path: "true" applies (if set). Thus, if you 
have a prefix, like /rest/namespace before /api/v1/hello (as in the example above), that prefix is included in the evaluation.
Thus, the regex in the example above contains `/.+/` in the beginning. 

## Important notes
* If ANY of the criteria are met for a given request, authentication will be required. 
* If you need more advanced control than this, it is recommended that you control this application-side, as all the auth 
mechanisms forward headers containing user info to the upstream by default.

# Development
## Publishing to LuaRocks
1. Update the Rockspec file name and version 
2. Update the git tag when ready for a release: `git tag v0.1-0`
3. Run `git push`
4. If authorized, follow the instructions here to upload https://github.com/luarocks/luarocks/wiki/Creating-a-rock