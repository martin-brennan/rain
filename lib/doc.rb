require_relative 'parser'
require_relative 'doc_part'
require 'logger'

module Rain

  # used each time a file needs to be parsed.
  # contains all documentation parts in the file
  # as well as functionality to read through file
  # contents line-by-line.
  class Doc
    attr_accessor :parser, :type, :parts, :current_part, :lines, :title,
            :file_name, :file_contents, :file_ext

    @@open_response = nil
    @@open_response_id = nil
    @@open_param = nil
    @@open_param_type = nil
    @@open_param_default = nil
    @@log_lines = false

    # sets up the doc using the file name and contents
    # as a basis.
    def initialize(file_name, file_contents, log_lines = false)

      # set up basic options and defaults
      self.file_name = file_name
      self.file_contents = file_contents
      self.file_ext = File.extname(file_name)
      self.parts = []
      self.lines = 0
      @@log_lines = log_lines

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
      self.parts << self.current_part if !self.current_part.nil?
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

        # if there is no documentation for the result,
        # create a new part and then set the current part to nil.
        if result.nil?
          self.new_part
          self.current_part = nil
          next
        else

          # if new doc block is found with the current part == nil,
          # create a new part
          self.new_part if self.current_part.nil?
        end
        
        # log the result if the logger is enabled
        Logger.new(STDOUT).info(result) if @@log_lines

        # figure out what to do based on the result type
        case result[:tag]
        when :title
          self.title = result[:title]
        when :route
          self.current_part.set_route(result[:route])
        when :method
          self.current_part.set_method(result[:method])
        when :response

          # open the current response tag using the code as a key
          if result[:open]
            @@open_response = result[:code]
            @@open_response_id = result[:id]
          else
            @@open_response = nil
          end
        when :param

          # open the current param tag using the name as the key
          if result[:open]
            @@open_param = result[:name]
            @@open_param_type = result[:type]
            @@open_param_default = result[:default]
          else
            @@open_param = nil
          end
        when :doc

          # figure out if the doc needs to be added to an
          # open response or param tag
          if !@@open_response.nil?
            self.current_part.append_response(@@open_response.to_i, @@open_response_id, result[:text])
          elsif !@@open_param.nil?
            self.current_part.append_param(@@open_param, result[:text], @@open_param_type, @@open_param_default)
          else
            self.current_part.append_doc(result[:text])
          end
        end

        self.lines += 1
      end

      # add the part and create a new one
      self.new_part

      # remove any empty parts (for ruby docs)
      if self.type == :RUBY
        self.parts = self.parts.select{ |part| part.route != "//" }
      end
    end

    def to_hash
      return {
        file_name: self.file_name,
        file_contents: self.file_contents,
        file_ext: self.file_ext,
        title: self.title,
        lines: self.lines,
        parts: self.parts.map { |part| part.to_hash },
        type: self.type.to_s
      }
    end
  end
end