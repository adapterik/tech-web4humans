# Auth Brainstorm

Initial version will be in-house.

Make separate table, so easier to refactor

Have log table, to be able to audi sign ins

We will have sessions, stored in a separate table. Sessions have a lifetime (expiration time). We may rotate the session id with every request. This would allow us to have short lifetimes without inconveniencing users (too much.)

The session id will be stored in a cookie (Authorization: SESSION_ID).

