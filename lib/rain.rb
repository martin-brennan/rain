require 'thor'
require 'erb'
require 'ostruct'
require 'fileutils'

class Rain::CLI < Thor
	@@docs = []

	desc "generate [file/sources/**]", "Generates the rain documentation"
	method_option :log_parse, aliases: "--lp", desc: "Show the output of each line parse"
	def generate(*sources)
		print "Rain is parsing files in the directories #{sources} \n"

		# loop through all of the file sources and generate docs
		sources.each do |source|
			print "Parsing #{source} \n"
			@doc = Rain::Doc.new(source, File.read(Dir.pwd + "/#{source}"), options[:log_parse])
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
		def build_html

			# delete the old output files and create the dir
			FileUtils.rm_rf('./rain_out')
			Dir.mkdir('./rain_out')
			Dir.mkdir('./rain_out/css')

			# copy the template css to the output dir
			FileUtils.cp_r './templates/css/.', './rain_out/css'

			# load the templates
			layout_template = File.read('./templates/layout.erb')
			doc_template = File.read('./templates/doc.erb')

			# load the doc properties and parts into the doc template
			@@docs.each do |doc|

				# create an openstruct from the current doc and render into the template
				doc_os = OpenStruct.new(doc.to_hash)
				doc_rendered = ERB.new(doc_template).result(doc_os.instance_eval {binding})

				# create a struct with the rendered doc output then render into the layout
				layout_os = OpenStruct.new({ doc_output: doc_rendered, title: doc_os.title })
				html = ERB.new(layout_template).result(layout_os.instance_eval {binding})

				# write the html to a file
				output_html(doc, html)
			end
		end

		def output_html(doc, html)
			# replace file_name extenstions with .html
			file_name = File.basename(doc.file_name, doc.file_ext) + '.html'

			# write the output to the file
			File.open("./rain_out/#{file_name}", 'w') { |file| file.write(html) }
		end
	end
end