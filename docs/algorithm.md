# Algorithm

In which we describe how it works, a bit more abstractly.

## Purpose - the end result

This site serves two purposes.

Primarily it serves to distribute my writing about Adaptations and computer technology related topics.

Secondarily it serves as an editor for this content.

## Exposition

### Display of Content

In the beginning, there is an execution environment (Ruby) which has been provided instructions for running an http server. This server is meant to be proxied to, so operates on "http" rather than "https".

Let us only consider the rules for displaying content.

The server receives a request, interprets it in the context of a certain set of rules, and returns an html document, which is displayed to the user in the browser. 

The server knows how to receive a request for a Page, and Article, and a Blog Entry. We call these "content items".

The server recieves such a request by means of a URL path with a simple string identifying the item requested. A simple string is technically a url path component, and must follow the rules for such.

If the request does not result in a content item, this fact will be communicated to the user in the form of an error message html document.

Interpretation depends not upon the form of the url, but the nature of the content item found. The content item will be either a Page, Article, or Blog Entry. We call a type of item a "content type".

Each of these content types is defined by a set of fields, which we call a "content type definition". Content types may share a defintion.

After a content item is found from a request, it is rendered into a form which may be displayed to the user. Each content type has a distinct rendering, even if it shares a definition (structure) with others.

### Content Types

#### Page

#### Article

#### Blog Entry


### Organization of Content

#### System

#### Pages

#### Articles

#### Blog
