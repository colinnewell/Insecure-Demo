# u2f implementation

U2F 2FA auth was implemented partly to see how it was done, and partly to
demonstrate that even if implemented right, it was possible to keep security
holes.  The u2f implementation isn't deliberately broken, but it's not
guaranteed to be perfect.  This was implemented in 2019.

* `lib/Insecure/Demo/Admin/Config.pm` - web server paths for registering u2f for users
* `lib/Insecure/Demo/Admin/Login.pm` - general u2f web server paths
* `lib/Insecure/Demo/Service/Users.pm` - database code for storing the u2f info
* `lib/Insecure/Demo/Service/U2F.pm` - makes the u2f lib calls
* `views/u2f-register.tt` - u2f registration page for users
* `views/u2f-auth.tt` - u2f auth page for users logging ni
* `public/ext/u2f-api.js` - js from ubikey (not updated recently)
* `libu2f-server-dev` - debian package required for the library bindings to work

The obviously insecure bit relates to cookies, not the u2f itself.

The bit I wasn't sure about when implementing this I believe related to the
challenges.  It wasn't clear to me whether I should be providing that to the
user and relying on what I was given back to me when verifying.  I decided to
pass it to the user for simplicity, and that may be a mistake.  There was
certainly a part where I wasn't clear if I should be providing it in the
javascript and simply having the client send it back to me.  This note is being
written several years later and I'm assuming that the potentially problematic
bit is where I left the FIXME.
