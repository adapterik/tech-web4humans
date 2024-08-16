# Content Types

So, content for display is organized by type. So far, we really just have Page.

Better to think of this (and we should adjust our terminology appropriately, now that I think about this) as endpoint handlers. An endpoint mapping (currently the "content" table) has an associated "type" (currently "content_type"); a type has an associated class to handle requests of that type.

Hmm...

Without making this too complicated ...

To handle POST, PUT, DELETE, perhaps what we really need is a table per request type. They each have specific needs. And thinking about the handling of requests, it makes sense to have a table to define handlers for each one, and to have a different base class for each type of handler.