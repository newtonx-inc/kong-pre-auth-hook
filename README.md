# Kong PreAuth Hook
A Kong plugin for performing operations before auth plugins run

**kong-pre-auth-hook** performs a few customizable operations before auth plugins run, such as stripping auth headers
that can be spoofed by requesters, and allowing for more finer grained control of whether auth plugins should run
or not based on the request.

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
* `X-User-Info` (used by kong-oidc-google-groups plugin)
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
export KONG_PLUGINS=bundled,kong-pre-auth-hook
```

# Requirements
* Kong auth plugins to be used in conjunction (e.g. oauth2, key-auth, jwt, etc.)

# Dependencies
None

# Configuration

| Parameter     | Default | Required? | Description                                                                                                         |
|---------------|---------|-----------|---------------------------------------------------------------------------------------------------------------------|
| strip_headers | {}      | No        | Additional headers to strip out before the upstream request                                                         |
| match_methods |         | No        | HTTP Methods to require authentication on                                                                           |
| match_paths   |         | No        | Paths to require authentication on                                                                                  |
| match_hosts   |         | No        | Hosts to require authentication on                                                                                  |
| match_headers |         | No        | Headers to require authentication on                                                                                |
| anonymous     |         | No        | Consumer ID to use as an "anonymous" consumer if auth fails. Used for "logical OR" in Kong multiple authentication. |

## Important notes
* If ANY of the match_* criteria are met for a given request, authentication will be required. 
* If you need more advanced control than this, it is recommended that you control this application-side.

# Development
## Publishing to LuaRocks
1. Update the Rockspec file name and version 
2. Update the git tag when ready for a release: `git tag v0.1-0`
3. Run `git push`
4. If authorized, follow the instructions here to upload https://github.com/luarocks/luarocks/wiki/Creating-a-rock