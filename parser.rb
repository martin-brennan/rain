require 'json'
@current_block = {}
@line_index = 1
@doc_part_store = []
@open_tag = nil

@http_method_regex = /(GET|PUT|POST|DELETE|PATCH|HEAD)/
@http_route_regex = /{route (.*?)}/m
@http_response_regex = /{response (.*?)}/m

def is_method?(line)
	if line.start_with? "{method"
		@current_block[:method] = line.match(@http_method_regex)[0]
		return true
	end
	return false
end

def is_route?(line)
	if line.start_with? "{route"
		@current_block[:route] = line[@http_route_regex, 1]
		return true
	end
	return false
end

def is_doc?(line)
	line = "\n" if line == ""

	if @open_tag.nil?
		if @current_block[:doc].nil?
			@current_block[:doc] = [line]
		else
			@current_block[:doc] << line
		end
	else
		if @open_tag[:tag] == 'RESPONSE'
			if @current_block[:response].nil?
				@current_block[:response] = { @open_tag[:meta] => [line] }
			else
				if @current_block[:response][@open_tag[:meta]].nil?
					@current_block[:response][@open_tag[:meta]] = [line]
				else
					@current_block[:response][@open_tag[:meta]] << line
				end
			end
		end
	end
end

def is_response?(line)
	if line.start_with? "{resp"
		code = line[@http_response_regex, 1]
		@open_tag = { tag: 'RESPONSE', meta: code }
		return true
	elsif line.start_with? "{/resp"
		@open_tag = nil
		return true
	end
	return false
end

File.open("#{Dir.pwd}/parsefile.rb", "r").each_line do |line|
	line.strip!

	if line.start_with? '#'
		line.sub!('#', '')
		line.strip!

		if @current_block.empty?
			@current_block[:line_start] = @line_index
		end

		skip_doc = false

		(skip_doc = true) if is_method?(line)
		(skip_doc = true) if is_route?(line)
		(skip_doc = true) if is_response?(line)
		
		is_doc?(line) unless skip_doc

	else
		if !@current_block.empty?
			@current_block[:line_end] = @line_index
			@doc_part_store << @current_block
			@current_block = {}
		end
	end

	@line_index += 1
end

p @doc_part_store
p JSON.pretty_generate(eval(@doc_part_store[0][:response]["200"].join))
p @doc_part_store[0][:doc].join('\n')

# rules

# declaration
# 
# {method} GET
# {route} /v1/app/auth
# {doc}
# Hello this is the first route
# {/doc}
#
# {response 200}
# {
# 	id: 3294,
# 	name: "martin brennan"
# }
# {/response}