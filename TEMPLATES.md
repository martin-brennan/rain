# Templates

The template system for Rain is designed to be almost too simple. There are three main templates that are used to construct the output (all ERB files):

1. templates/doc.erb
2. templates/layout.erb
3. templates/nav.erb

The basic versions of these templates are included with the gem, though **they will be overridden with any templates you provide with the same file name/path**.

## layout.erb

This template controls the layout of the navigation and the main doc area, as well as providing a place for CSS and JS file referencing. Below is an overview of the variables used:

|name|description|
|----|-----------|
|title|The doc's title. Will be a proper-case version of the file name with no symbols if the `{title}` tag is not found in the parsed file.|
|nav_parts|An array of navigation parts, which contain the main page link as well as sub-section links for routes and signatures. These parts are an output of the `nav.erb` template.|
|doc_output|The output of the `doc.erb` template and the main content of the page.|