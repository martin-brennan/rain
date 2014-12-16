require 'parser'
require 'doc_part'

module Rain

  # used each time a file needs to be parsed.
  # contains all documentation parts in the file
  # as well as functionality to read through file
  # contents line-by-line.
  class Doc
    attr_accessor :parser, :type, :parts, :current_part, :lines, :title,
            :file_name, :file_contents, :file_ext

    @@open_response = nil
    @@open_param = nil

    # sets up the doc using the file name and contents
    # as a basis.
    def initialize(file_name, file_contents)

      # set up basic options and defaults
      self.file_name = file_name
      self.file_contents = file_contents
      self.file_ext = File.extname(file_name)
      self.parts = []
      self.lines = 0

      # set the doc type based on extension
      case self.file_ext
      when '.rb'
        self.type = :RUBY
      when '.md', '.txt', '.markdown', '.mdown'
        self.type = :MARKDOWN
      end

      # set parser with file type
      self.parser = Rain::Parser.new(self.type)

      # set the default title to the proper-case file name
      # without the extension and underscores/dashes
      self.title = self.file_name.sub(self.file_ext, '')
      self.title.gsub!(/_|-/, ' ')

      # very simple proper-caser
      self.title.gsub!(/\w+/) { |word| word.capitalize }
    end

    # adds the current part to the parts array
    # then sets a new current part up. a part is just
    # a completed DocPart from a section of comments.
    # for markdown files there will only be one doc part.
    def new_part
      self.parts << self.current_part
      self.current_part = Rain::DocPart.new
    end

    # parses the file by looping through all of the lines.
    # defers to parser functionality to figure out if the
    # current line is a tag and needs to be parsed into
    # the docpart.
    def parse
      self.new_part
      self.file_contents.each_line do |line|

        # parse the current line
        result = self.parser.parse(line)

        # figure out what to do based on the result type
        case result[:type]
        when :title
          self.title = result[:title]
        when :route
          self.current_part.set_route(result[:route])
        when :method
          self.current_part.set_method(result[:method])
        when :response
          if result[:open]
            @@open_response = result[:code]
          else
            @@open_response = nil
          end
        when :param
          if result[:open]
            @@open_param = result[:name]
          else
            @@open_param = nil
          end
        when :doc
          if !@@open_response.nil?
            self.current_part.append_response(@@open_response.to_i, response[:id], response[:text])
          end
          if !@@open_param.nil?
            self.current_part.append_param(@@open_param, response[:text], response[:type], response[:default])
          end
        end

        self.lines += 1
      end
    end
  end
end