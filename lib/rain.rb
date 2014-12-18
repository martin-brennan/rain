require 'thor'
require 'erb'
require 'ostruct'
require 'fileutils'

class Rain::CLI < Thor
	@@docs = []

	desc "generate [file/sources/**]", "Generates the rain documentation"
	method_option :log_parse, aliases: "--lp", desc: "Show the output of each line parse."
	method_option :parse_signatures, aliases: "--s", desc: "Parse method and class documentation too. Defaults to false."
	def generate(*sources)
		print "Rain is parsing files in the directories #{sources} \n"

		# loop through all of the file sources and generate docs
		sources.each do |source|
			print "Parsing #{source} \n"
			@doc = Rain::Doc.new(source, File.read(Dir.pwd + "/#{source}"), options[:log_parse].nil? ? false : true, options[:parse_signatures].nil? ? false : true)
			@doc.parse

			@@docs << @doc
		end

		print "\nBuilding html output... \n"
		build_html
	end

	# define the ascii art for the help command
	desc "help", "Shows rain help documentation"
	def help
		print "       _      \n"
		print "     _( )_    \n"
		print "   _(     )_  \n"
		print "  (_________) \n"
		print "    \\ \\ \\ \\ \n"
		print "     \\ \\ \\ \\ \n"
		print "              \n"
		print "---- RAIN ----\n"
		print "              \n"
		print "basic usage:\n"
		print "  rain generate file/**/*.rb\n"
	end

	no_commands do

		# Builds the HTML for each doc in the @@docs array.
		def build_html

			# delete the old output files and create the dir
			FileUtils.rm_rf('./rain_out')
			Dir.mkdir('./rain_out')
			Dir.mkdir('./rain_out/css')

			# check if there are local templates before copying from gem dir
			if File.exist?('./templates/') && File.exist?('./templates/css/')

				# copy the template css to the output dir
				FileUtils.cp_r './templates/css/.', './rain_out/css'

				# load the templates
				layout_template = File.read('./templates/layout.erb')
				doc_template = File.read('./templates/doc.erb')
				nav_template = File.read('./templates/nav.erb')

			else

				# copy the templates from the gem directory
				spec = Gem::Specification.find_by_name("rain-doc")
				FileUtils.cp_r spec.gem_dir + '/templates/css/.', './rain_out/css'

				# load the templates
				layout_template = File.read(spec.gem_dir + '/templates/layout.erb')
				doc_template = File.read(spec.gem_dir + '/templates/doc.erb')
				nav_template = File.read(spec.gem_dir + '/templates/nav.erb')
			end

			# loop through all of the docs and generate navigation from the docs and their parts
			nav_parts = []
			@@docs.each do |doc|

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
								url: "#{html_file_name}##{part[:route].gsub('/', '-').gsub(':', '')}"
							}
						end
					end
				end

				# render the nav and append it to the array of nav parts
				nav_os = OpenStruct.new(nav)
				nav_rendered = ERB.new(nav_template).result(nav_os.instance_eval {binding})
				nav_parts << nav_rendered
			end

			# load the doc properties and parts into the doc template
			@@docs.each do |doc|

				# create an openstruct from the current doc and render into the template
				doc_os = OpenStruct.new(doc.to_hash)
				doc_rendered = ERB.new(doc_template).result(doc_os.instance_eval {binding})

				# create a struct with the rendered doc output then render into the layout with nav
				layout_os = OpenStruct.new({ doc_output: doc_rendered, title: doc_os.title, nav_parts: nav_parts })
				html = ERB.new(layout_template).result(layout_os.instance_eval {binding})

				# write the html to a file
				output_html(doc, html)
			end
		end

		# Creates the html file for the specified doc
		# with the HTML rendered from the ERB template
		# 
		# {param doc hash}
		# 	A hash representation of the Rain::Doc class, containing a single document and its parts.
		# {/param}
		# {param html string}
		# 	The HTML rendered from the ERB layout and doc template.
		# {/param}
		def output_html(doc, html)

			# replace file_name extenstions with .html
			file_name = File.basename(doc.file_name, doc.file_ext) + '.html'

			# write the output to the file
			File.open("./rain_out/#{file_name}", 'w') { |file| file.write(html) }
		end
	end
end