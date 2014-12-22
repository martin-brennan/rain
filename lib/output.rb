module Rain
  class Output

    # Builds the HTML for each doc in thedocs array after
    # parsing all of the files specified.
    def build_html(docs, rainopts)

      # delete the old output files and create the dir
      FileUtils.rm_rf('./rain_out')
      Dir.mkdir('./rain_out')
      Dir.mkdir('./rain_out/css')
      Dir.mkdir('./rain_out/js')
      Dir.mkdir('./rain_out/img')

      # check if there are local templates before copying from gem dir
      if File.exist?('./templates/') && File.exist?('./templates/css/')

        # copy the template css + js to the output dir
        FileUtils.cp_r './templates/css/.', './rain_out/css'
        FileUtils.cp_r './templates/js/.', './rain_out/js'
        FileUtils.cp_r './templates/img/.', './rain_out/img'

        # load the templates
        layout_template = File.read('./templates/layout.erb')
        doc_template = File.read('./templates/doc.erb')
        nav_template = File.read('./templates/nav.erb')

      else

        # copy the templates from the gem directory
        spec = Gem::Specification.find_by_name("rain-doc")
        FileUtils.cp_r spec.gem_dir + '/templates/css/.', './rain_out/css'
        FileUtils.cp_r spec.gem_dir + '/templates/js/.', './rain_out/js'
        FileUtils.cp_r spec.gem_dir + '/templates/img/.', './rain_out/img'

        # load the templates
        layout_template = File.read(spec.gem_dir + '/templates/layout.erb')
        doc_template = File.read(spec.gem_dir + '/templates/doc.erb')
        nav_template = File.read(spec.gem_dir + '/templates/nav.erb')
      end

      # loop through all of the docs and generate navigation from the docs and their parts
      nav_parts = []
      docs.each do |doc|
        nav_parts << render_nav(doc, nav_template)
      end

      # load the custom css file paths from templates/css.
      custom_css = find_custom_css

      # load the custom js file paths from templates/js.
      custom_js = find_custom_js

      # load the doc properties and parts into the doc template
      docs.each do |doc|

        # create an openstruct from the current doc and render into the template
        doc_os = OpenStruct.new(doc.to_hash)
        doc_rendered = ERB.new(doc_template).result(doc_os.instance_eval {binding})

        # create a struct with the rendered doc output then render into the layout with nav
        layout_os = OpenStruct.new({
          doc_output: doc_rendered,
          title: doc_os.title,
          nav_parts: nav_parts,
          custom_css: custom_css,
          custom_js: custom_js,
          rainopts: rainopts
        })

        html = ERB.new(layout_template).result(layout_os.instance_eval {binding})

        # write the html to a file
        output_html(doc, html)
      end
    end

    # renders the nav block for the doc specified,
    # including the navigation tree for subitems.
    #
    # {param doc Rain::Doc}
    #   The doc to use for the navigation block.
    # {/param}
    # {param nav_template String}
    #   The navigation template from templates/nav.erb
    # {/param}
    def render_nav(doc, nav_template)

      # get the html file name (same used for output) from the doc openstruct
      doc_os = OpenStruct.new(doc.to_hash)
      html_file_name = File.basename(doc_os.file_name, doc_os.file_ext) + '.html'

      # set up the nav hash for the doc
      nav = {
        navdoc: {
          title: doc_os.title,
          url: "#{html_file_name}",
          parts: []
        }
      }

      # markdown docs do not have parts as the whole page counts as a "doc"
      if doc_os.type != "MARKDOWN"

        # loop through all of the parts and depending on whether
        # it is for a signature or a route, construct the #anchor
        # url differnetly
        doc_os.parts.each do |part|
          if !part[:signature].nil?
            nav[:navdoc][:parts] << {
              title: part[:signature],
              url: "#{html_file_name}##{part[:signature].gsub(' ', '-').gsub(',', '').gsub('(', '-').gsub(')', '-')[0..12]}"
            }
          else
            nav[:navdoc][:parts] << {
              title: part[:route],
              url: "#{html_file_name}##{part[:http_method].downcase}#{part[:route].gsub('/', '-').gsub(':', '')}"
            }
          end
        end
      end

      # render the nav and append it to the array of nav parts
      nav_os = OpenStruct.new(nav)
      nav_rendered = ERB.new(nav_template).result(nav_os.instance_eval {binding})
    end

    # loads the custom css files (e.g. not skeleton, normalise and rain.css)
    # from the templates/css path.
    def find_custom_css

      # loop through all of the css files in the output dir
      # to see if any are custom files.
      default_files = ['skeleton.css', 'normalize.css', 'rain.css']
      custom_css = []
      Dir.foreach('./rain_out/css') do |file_name|
        if !default_files.include?(file_name) && file_name != '.' && file_name != '..'
          custom_css << "css/#{file_name}"
        end
      end

      custom_css
    end

    # loads the custom js files (e.g. not skeleton, normalise and rain.js)
    # from the templates/js path.
    def find_custom_js

      # loop through all of the js files in the output dir
      # to see if any are custom files.
      custom_js = []
      Dir.foreach('./rain_out/js') do |file_name|
        if file_name != '.' && file_name != '..'
          custom_js << "js/#{file_name}"
        end
      end

      custom_js
    end

    # Creates the html file for the specified doc
    # with the HTML rendered from the ERB template
    # 
    # {param doc hash}
    #   A hash representation of the Rain::Doc class, containing a single document and its parts.
    # {/param}
    # {param html string}
    #   The HTML rendered from the ERB layout and doc template.
    # {/param}
    def output_html(doc, html)

      # replace file_name extenstions with .html
      file_name = File.basename(doc.file_name, doc.file_ext) + '.html'

      # write the output to the file
      File.open("./rain_out/#{file_name}", 'w') { |file| file.write(html) }
    end

  end
end