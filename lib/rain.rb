require 'thor'
require 'erb'
require 'ostruct'
require 'fileutils'
require 'yaml'

class Rain::CLI < Thor

  # loops through all of the specified source
  # files, parses them line by line and produces
  # doc and docpart output
  desc "generate [file/sources/**]", "Generates the rain documentation"
  method_option :log_parse, aliases: "--lp", desc: "Show the output of each line parse."
  method_option :parse_signatures, aliases: "--s", desc: "Parse method and class documentation too. Defaults to false."
  def generate(*sources)
    print "Rain is parsing files in the directories #{sources} \n"

    # loop through all of the file sources and generate docs
    all_docs = []
    sources.each do |source|
      print "Parsing #{source} \n"
      @doc = Rain::Doc.new(source, File.read(Dir.pwd + "/#{source}"), options[:log_parse].nil? ? false : true, options[:parse_signatures].nil? ? false : true)
      @doc.parse

      all_docs << @doc
    end

    # load the rainopts.yml file from local location (if it exists). otherwise use the default
    # one from the gem dir.
    if File.exist?('./rainopts.yml')
      rainopts = YAML.load_file('./rainopts.yml')
    else
      spec = Gem::Specification.find_by_name("rain-doc")
      rainopts = File.read(spec.gem_dir + '/rainopts.yml')
    end

    print "\nBuilding html output... \n"
    Rain::Output.new.build_html(all_docs, rainopts)
    print "\nDone! See rain_out/ directory for output.\n"
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
    print "options:\n"
    print "  --lp logs all line parsing output to console\n"
    print "  --s  generates docs for methods and class signatures\n"
  end
end