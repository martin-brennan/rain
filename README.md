rain is a ruby api documentation tool inspired by yard and rdoc

the aim of rain is to generate beautiful api documentation from a ruby comment syntax with markdown mixed in

the doucmentation can be inline in .rb files, or separate .md or .txt files for overall architecture documentation

rain also allows a large amount of customization when it comes to templating and appearance of the api documentation. branding and unity of documentation appearance is important and rain offers a simple ebr-based template system

### class structure
Rain::Doc
- handles looping through files
- determines whether the file needs to be parsed as .rb file or .md file
- stores the docoumentation in-memory as it is generated

Rain::Parser
- handles reading through the file, determining how to construct the current doc bloc
- checks through all of the available tags and adds then to the current block

Rain::DocPart
- Stores information about the current documentation block
- E.g. stores method, doc, route, responses, params
- Model mostly

Rain::TagDefinition
- checks whether a line is a tag
- parses information out of the tag

documentation is titled like so for .rb files
- {title ksldk} tag
- class name
- file name

documentation is titled like so for .md, .txt etc files
- {title} tag
- file name


### tags
- title - The title of the current group of blocks (e.g. file)
- method - HTTP route method
- route - The REST api route
- response - Can be combined with status. HTTP response examples. Can be > 1
- doc - The rest of non-tagged is just descriptive documentation
- param - The api params, with type and default values
- deperecated - Reasons for deprecation etc.

{title This is the title}
{method GET}
{route /person/:id}
{response 200}
{
  a: 1
}
{/response}
These lines
are the
docs
{param id integer}
This is the param description
{/param}
{deprecated Because this route is bad}