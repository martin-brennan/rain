## 0.0.6 (2014-12-20)

- Added custom CSS styles on top of skeleton framework for method and route
- Fixed doc arrays for params and headers
- Made some other small CSS changes
- Added a complex_rb test file with every type of route & method

## 0.0.5 (2014-12-20)

Bugixes:

- Added proper header support and output
- Fixed headers and params to support multiline docs
- Added header output to basic doc template
- Changed default route value to nil instead of //

## 0.0.4 (2014-12-18)

Features:

- Added simple sidebar for documentation that links to docs and their parts
- Added the signature tag, which reads the next line after the documentation ends to get
the method signature or class (for docs that aren't to do with API routes)

## 0.0.3 (2014-12-18)

Bugfixes:

- Fixes loading template files. Files now load from current path or failing that, the rain gem dir.
- Added extra template css files to gemspec.

Documentation:

- Added more updated information into the README. Added header image to the readme.

## 0.0.2 (2014-12-17)
- Push to rubygems.org and name change to rain-doc (http://rubygems.org/gems/rain-doc)

## 0.0.1
- Basic functionality completed.
- Full test suite under spec/