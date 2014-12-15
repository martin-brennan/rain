module Rain
	class TagDesignator
		attr_accessor :http_method_regex, :http_route_regex, :http_response_regex
		
		def initialize
			self.http_method_regex = /(GET|PUT|POST|DELETE|PATCH|HEAD)/
			self.http_route_regex = /{route (.*?)}/m
			self.http_response_regex = /{response (.*?)}/m
		end

		def is_method?(line)
			if line.start_with? "{method"
				$current_block[:method] = line.match(self.http_method_regex)[0]
				return true
			end
			return false
		end

		def is_route?(line)
			if line.start_with? "{route"
				$current_block[:route] = line[self.http_route_regex, 1]
				return true
			end
			return false
		end

		def is_doc?(line)
			line = "\n" if line == ""

			if $open_tag.nil?
				if $current_block[:doc].nil?
					$current_block[:doc] = [line]
				else
					$current_block[:doc] << line
				end
			else
				if $open_tag[:tag] == 'RESPONSE'
					if $current_block[:response].nil?
						$current_block[:response] = { $open_tag[:meta] => [line] }
					else
						if $current_block[:response][$open_tag[:meta]].nil?
							$current_block[:response][$open_tag[:meta]] = [line]
						else
							$current_block[:response][$open_tag[:meta]] << line
						end
					end
				end
			end
		end

		def is_response?(line)
			if line.start_with? "{resp"
				code = line[self.http_response_regex, 1]
				$open_tag = { tag: 'RESPONSE', meta: code }
				return true
			elsif line.start_with? "{/resp"
				$open_tag = nil
				return true
			end
			return false
		end
	end
end