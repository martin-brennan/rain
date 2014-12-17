module Rain
  class DocPart
    attr_accessor :http_method, :responses, :route, :doc, :params, :headers

    def initialize
      self.responses = {}
      self.doc = []
      self.route = '//'
      self.params = []
      self.headers = []
    end

    # add or append a response with the specified code
    # and the line of text passed in
    def append_response(code, id, text)

      # check that the response code is a number
      begin
        code.to_i
      rescue Exception => e
        raise ArgumentError, 'You can only use integer codes for HTTP response examples.'
      end

      # set defaults if the identifiers do not exist
      self.responses[code] = {} if self.responses[code].nil?
      self.responses[code][id.to_sym] = [] if self.responses[code][id.to_sym].nil?

      self.responses[code][id.to_sym] << text
    end

    # gets a response part by code and id and
    # joins the parts of the text
    def get_response(code, id)
      response = self.responses[code][id.to_sym]

      raise 'Response code and id reference does not exist.' if response.nil?

      response.join
    end

    # sets the http method for the
    # documentation part
    def set_method(method)

      # capitalize and convert to a symbol if not already a symbol
      method.upcase! if !method.kind_of? Symbol

      # check if the http method is valid
      valid_methods = [:GET, :PUT, :POST, :PATCH, :DELETE]
      if !valid_methods.include?(method.to_sym)
        raise ArgumentError, "HTTP method must be valid (#{valid_methods.join(', ')})"
      end

      self.http_method = method
    end

    # appends the text to the current documentation for the part
    def append_doc(text)
      self.doc << text
    end

    # joins all of the text in the doc property of
    # the part with spaces
    def get_doc
      self.doc.join(' ')
    end

    # sets the current route for the doc part
    def set_route(path)
      self.route = path
    end

    # gets the current route for the doc part
    def get_route
      self.route
    end

    # adds a parameter with the specified type. also sets a
    # default value if specified
    def append_param(name, description, type, default = nil)
      self.params << {
        name: name,
        text: description,
        type: type,
        default: default
      }
    end

    # gets a parameter by name. will return nil if
    # the parameter does not exist
    def get_param(name)
      self.params.select { |param| param[:name] == name }.first
    end

    # adds a http header with name and
    # description of the header
    def append_header(name, description)
      self.headers << {
        name: name,
        text: description
      }
    end

    # gets a header's description from the store
    def get_header(name)
      header = self.headers.select { |h| h[:name] == name }.first

      return nil if header.nil?

      return header[:text]
    end

    def to_hash
      return {
        route: self.route,
        params: self.params,
        headers: self.headers,
        doc: self.doc,
        responses: self.responses,
        http_method: self.http_method
      }
    end
  end
end