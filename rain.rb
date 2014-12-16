require 'thor'

class Rain::CLI < Thor
	@@docs = []

	desc "generate [file/sources/**]", "Generates the rain documentation"
	def generate(*sources)
		puts "Rain is parsing files in the directories #{sources}"

		# loop through all of the file sources and generate docs
		sources.each do |source|
			@doc = Rain::Doc.new(source, File.read(Dir.pwd + "/#{source}"))
			@doc.parse

			@@docs << @doc
		end

		build_html
	end

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
			@@docs.each do |doc|
				p doc.parts[0].doc
			end
		end
	end
end