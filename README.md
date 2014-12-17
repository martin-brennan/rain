![Rain](img/rain.png)

# Rain

[![Gem Version](https://badge.fury.io/rb/rain-doc.svg)](http://badge.fury.io/rb/rain-doc)

Rain is a gem to generate beautiful and customizable API documentation, inspired by yard and rdoc.

The aim of rain is to generate beautiful API documentation from a ruby comment syntax with markdown mixed in.

The documentation can be inline in .rb files, or separate .md or .txt files for overall architecture documentation.

Rain also allows a large amount of customization when it comes to templating and appearance of the API documentation. branding and unity of documentation appearance is important and rain offers a simple ebr-based template system.

Rain is still currently a WIP and not a completely stable release. All parsing and file reading functionality is complete as is template output, but the actual template layout and styles are still being worked on.

[See the Rain homepage (also WIP)](http://martin-brennan.github.io/rain)

[See a basic example of output](img/rain-basic-rb.png)

## Installation
Simply install from rubygems.org. This will install the gem, the `raindoc` executable and the template files for the gem.

```
gem install rain-doc
```

## Usage
Use the CLI provided (via Thor) to run the following command:

```
raindoc generate <file/paths/*>
```

Where file/paths are a list of `.md, .markdown, .txt, .mdown or .rb` files.

## Tags and Usage in Files
There are several different tags that can be used in Rain. Here are their descriptions and below, an example of all of them together.

- title - The title of the current group of blocks (e.g. file). This should only be used once per file.
- method - HTTP route method.
- route - The API route that is being documented.
- response - Can be combined with status. HTTP response examples. Can be more than one of the same code. Needs a unique identifier as well as the code e.g. OK.
- doc - The rest of non-tagged comments/docs is just descriptive documentation. In the case of response and params tags, the docs contribute to that tag's description.
- param - The api params, with type and default values.
- header - A HTTP header that is required for the route.

```ruby
# These are the docs that are not related
# to any tags
# 
# {title This is the title}
# {method GET}
# {route /person/:id}
#
# {response 200 ok}
# {
#   a: 1
# }
# {/response}
# 
# {param id integer default_value}
#   This is the param description
# {/param}
```

## Class Structure

Rain::Doc
- handles looping through files
- determines whether the file needs to be parsed as .rb file or .md file
- stores the docoumentation in-memory as it is generated
- passes all lines to the parser
- decides what to do with the returned information

Rain::Parser
- handles reading through the file, determining how to construct the current doc bloc
- checks through all of the available tags and adds then to the current block

Rain::DocPart
- Stores information about the current documentation block
- Stores method, doc, route, responses, params
- Storage model for all of the different parts of each block