# Design

A simple rack with puma web site.

Templating with erb.

Data simply via json in data directory.

## Dependencies

### Ruby

Ruby dependencies are handled in the normal fashion, in a Gemfile.

### Javascript and CSS

Via npm.


## Data and Content

Content is stored in a local database. The data model is not complicated.

All content is stored in an sqlite database. This allows for easier and faster searching over content, keywords, and categorization.

Pages, Articles, and Blog Posts are stored as the same Content record. The content record is "generic" in that any content can be stored in it. A "type" field is used to allow for showing the content type in the editor.

The site structure is represented as a layout table...