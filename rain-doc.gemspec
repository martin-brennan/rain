Gem::Specification.new do |s|
  s.name        = 'rain-doc'
  s.version     = '0.0.7'
  s.licenses    = ['MIT']
  s.summary     = "Rain is a gem to generate beautiful and customizable API documentation, inspired by yard and rdoc."
  s.description = "Rain is a gem to generate beautiful and customizable API documentation, inspired by yard and rdoc. \
                   The aim of Rain is to generate beautiful API documentation from a ruby comment syntax with markdown mixed in. \ 
                   The documentation can be inline in .rb files, or separate .md or .txt files for overall architecture documentation. \
                   Rain also allows a large amount of customization when it comes to templating and appearance of the API documentation. \
                   Branding and unity of documentation appearance is important and Rain offers a simple ERB-based template system."
  s.authors     = ["Martin Brennan"]
  s.email       = 'mjrbrennan@gmail.com'
  s.files       = ["lib/rain.rb", "lib/parser.rb", "lib/doc.rb", "lib/doc_part.rb", "lib/output.rb", "rainopts.yml"] + Dir["templates/*.erb"] + Dir["templates/css/*.css"] + Dir["templates/img/*.png"]
  s.homepage    = 'http://martin-brennan.github.io/rain/'
  s.bindir      = 'bin'

  s.executables << 'raindoc'

  s.post_install_message = "Rain installed successfully! Run rain generate file/paths/*.rb to get started."

  s.add_development_dependency 'rspec', '3.1.0'
  s.add_development_dependency 'guard-rspec', '4.5.0'

  s.add_runtime_dependency 'thor', '0.19.1'
  s.add_runtime_dependency 'redcarpet', '3.2.2'
end