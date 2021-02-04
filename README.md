# Kong PreAuth Hook
TBD

# Brainstorm

* Strips out any headers that Kong plugins insert before authentication.
E.g. X-Consumer-Id, X-User-Info etc. because these can be spoofed by the 
originator of the HTTP request.
* Checks if any conditions for performing authentication are met (e.g.
matching HTTP method, Path, Host, or Headers). 
    * If YES, nothing is done, and the request flows upstream to the
    authentication plugins, if they exist. 
    * If NO, this plugin generates headers associated with an anonymous 
    consumer, so that upstream auth checks don't fail. In other words, 
    we skip authentication.



# Config
* skip auth if no match? 
* 

# Notes
* Authz is either on for all plugins on a certain match, or not at all. 
For more fine-grained control, manage that application side using 
upstream headers provided by Kong.

# Stripped headers
* X-Consumer-ID
* X-Consumer-Custom-ID
* X-Consumer-Username
* X-Credential-Identifier
* X-Anonymous-Consumer
* X-User-Info
* X-Auth-Mechanism
* X-Skip-Kong-Auth


