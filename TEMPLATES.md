# Templates

The template system for Rain is designed to be almost too simple. There are three main templates that are used to construct the output (all ERB files):

1. templates/doc.erb
2. templates/layout.erb
3. templates/nav.erb

The basic versions of these templates are included with the gem, though **they will be overridden with any templates you provide with the same file name/path**.

### CSS

Rain uses some basic CSS files under templates/css. They are `normalize.css` for resetting CSS defaults, `skeleton.css` for a basic CSS framework and style base and `rain.css` which mainly provides extra structural styles and some default styles for routes + methods.

Any extra CSS files you add will be automatically added to the `layout.erb` output in the header.

### JavaScript

The same goes for JavaScript files. Add any custom js files to templates/js and they will be inserted into the header for the HTML output of the layout.

## layout.erb

This template controls the layout of the navigation and the main doc area, as well as providing a place for CSS and JS file referencing. Below is an overview of the variables used:

|name|description|
|----|-----------|
|title|The doc's title. Will be a proper-case version of the file name with no symbols if the `{title}` tag is not found in the parsed file.|
|nav_parts|An array of navigation parts, which contain the main page link as well as sub-section links for routes and signatures. These parts are an output of the `nav.erb` template.|
|doc_output|The output of the `doc.erb` template and the main content of the page.|
|custom_css|An array of custom CSS files to link to in the templates/css directory.|

### rainopts.yml

The rainopts file is a set of settings used to customize the appearance of the rain output through global settings. If this file is not provided, then the one included with the gem will be used.

|setting|description|
|----|-----------|
|header_img_url|The url of the image to use in the top left of the header|
|api_title|The title of the API shown at the top of the page|
|api_url|The base url of the API|
|api_version|The version of the API that the docs are for|
|source_url|The url for the source code repo for the API|
|company_name|The name of the company who developed the API (shown in the footer)|

## doc.erb

This template structures the main part of the documentation for each file parsed by Rain, including information on routes, signatures, parameters, headers, and responses.

|name|description|
|----|-----------|
|parts|An array of lib/doc_parts (converted to a hash) constructed from parsing the file.|

Each doc part has the following properties:

|name|description|
|----|-----------|
|:route|The route path for the doc path. If this and the :http_method are not nil, then the route section of the layout should be shown|
|:http_method|The method of the part (GET, PUT, POST, DELETE, PATCH, HEAD)|
|:signature|The signature of the method or class. Used if the :route and :method are both nil|
|:doc|An array of doc lines for the part. These can be joined any way you like and can be processed as markdown.|
|:params|An array of params for the part. Each param has a :name, :type and :default (which is nullable). It also has a :text array of documentation lines (which can be markdown).|
|:headers|An array of headers for the part. Each param has a :header, and a :text array of documentation lines (which can be markdown).|
|:responses|An array of responses for the part. Each response has a :code, unique :id, and a :text array of documentation lines (which can be markdown). Usually the responses will be JSON or XML examples.|

### Anchors
Each route/signature has its own `id` for the `p` tag, used as an anchor for the navigation. This id is derived from the route or the signature itself, sans symbols and spaces. Make sure you include this or **navigation for sub-items will not work**.

## nav.erb

This template is used to construct the navigation tree for each parsed file. This is purely constructed in rain.rb.

|name|description|
|----|-----------|
|navdoc|The main navigation hash. Contains property for :url, which is the file url of the parsed file + .html, and :title which is also derived from the parsed file.|
|navdoc[:parts]|An array of sub-items to link to in the file (routes and signatures). These also have a :url, which is based on the `doc.erb` anchors, and a :title which is based on the route or signature.|