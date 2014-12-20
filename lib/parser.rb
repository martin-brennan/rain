module Rain
  class Parser
    attr_accessor :type, :current_line

    @@title_regex = /{title (.*?)}/m
    @@route_regex = /{route (.*?)}/m
    @@header_regex = /{header (.*?)}/m
    @@response_regex = /{response (.*?) (.*?)}/m
    @@param_regex = /{param (.*?) (.*?)}/m
    @@param_regex_default = /{param (.*?) (.*?) (.*?)}/m
    @@method_regex = /(GET|PUT|POST|DELETE|PATCH|HEAD)/

    def initialize(type)
      self.type = type
    end

    # parses the current line, determining which tag
    # the line contains and returning the result
    # accordingly in a hash with the tag type
    def parse(line, parse_signatures = false)

      # return nil if there is no # on the line for ruby.
      basic_stripped = line.strip().sub(' do', '')
      return nil if self.type == :RUBY && basic_stripped == ''

      # see if a signature part can be extracted if a signature is enabled
      if parse_signatures
        return nil if self.type == :RUBY && !basic_stripped.start_with?('#') && !(basic_stripped =~ /class|def|get|put|post|delete/)
      else
        return nil if self.type == :RUBY && !basic_stripped.start_with?('#')
      end

      # strip blanks and # from the current line
      line = strip_current_line(line)

      # convert blank lines to new lines
      if line == ""
        line = "\n"
      end

      # title tag
      if is_title?(line)
        return {
          tag: :title,
          title: extract_title(line)
        }
      end

      # method tag
      if is_method?(line)
        return {
          tag: :method,
          method: extract_method(line)
        }
      end

      # route tag
      if is_route?(line)
        return {
          tag: :route,
          route: extract_route(line)
        }
      end

      # response tag. must determine whether to open the tag
      # for extra docs or close it
      if is_response?(line)
        open = line.start_with?('{/response') ? false : true
        return {
          tag: :response,
          code: extract_response_code(line),
          open: open,
          id: extract_response_id(line)
        }
      end

      # param tag. must determine whether to open the tag
      # for extra docs or close it
      if is_param?(line)
        open = line.start_with?('{/param') ? false : true
        return {
          tag: :param,
          name: extract_param_name(line),
          type: extract_param_type(line),
          default: extract_param_default(line),
          open: open
        }
      end

      # param tag. must determine whether to open the tag
      # for extra docs or close it
      if is_header?(line)
        open = line.start_with?('{/header') ? false : true
        return {
          tag: :header,
          name: extract_header_name(line),
          open: open
        }
      end

      # return method signature if found
      if parse_signatures
        if line.start_with?('def ', 'class ', 'get "', "get '", 'put "', "put '", 'post "', "post '", 'delete "', "delete '")
          return {
            tag: :signature,
            text: line
          }
        end
      end

      # return simple doc line if no tags fit
      return {
        tag: :doc,
        text: line
      }
    end

    # remove any extra spaces from the current line
    # and remove the comma # at the start of the
    # line if the parser is for a ruby file
    def strip_current_line(line)
      line.strip!

      # check the current type and if ruby, remove the #
      if self.type == :RUBY
        line.sub!('#', '')
        line.strip!
      end

      return line
    end

    def is_title?(line)
      line.start_with? '{title'
    end

    def extract_title(line)
      line[@@title_regex, 1]
    end

    def is_method?(line)
      line.start_with? '{method'
    end

    def extract_method(line)
      line[@@method_regex, 1]
    end

    def is_route?(line)
      line.start_with? '{route'
    end

    def extract_route(line)
      line[@@route_regex, 1]
    end

    def is_response?(line)
      line.start_with?('{response') || line.start_with?('{/response')
    end

    def extract_response_code(line)
      line[@@response_regex, 1]
    end

    def extract_response_id(line)
      line[@@response_regex, 2]
    end

    def is_param?(line)
      line.start_with?('{param') || line.start_with?('{/param')
    end

    def extract_param_name(line)
      line[@@param_regex, 1]
    end

    def extract_param_type(line)
      if line[@@param_regex_default, 2].nil?
        return line[@@param_regex, 2]
      end

      return line[@@param_regex_default, 2]
    end

    def extract_param_default(line)
      line[@@param_regex_default, 3]
    end

    def is_header?(line)
      line.start_with?('{header') || line.start_with?('{/header')
    end

    def extract_header_name(line)
      line[@@header_regex, 1]
    end
  end
end