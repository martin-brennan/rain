require 'json'
require './lib/tag_designator.rb'

$current_block = {}
$line_index = 1
$doc_part_store = []
$open_tag = nil

tag = Rain::TagDesignator.new

File.open("#{Dir.pwd}/parsefile.rb", "r").each_line do |line|
	line.strip!

	if line.start_with? '#'
		line.sub!('#', '')
		line.strip!

		if $current_block.empty?
			$current_block[:line_start] = $line_index
		end

		skip_doc = false

		(skip_doc = true) if tag.is_method?(line)
		(skip_doc = true) if tag.is_route?(line)
		(skip_doc = true) if tag.is_response?(line)
		
		tag.is_doc?(line) unless skip_doc

	else
		if !$current_block.empty?
			$current_block[:line_end] = $line_index
			$doc_part_store << $current_block
			$current_block = {}
		end
	end

	$line_index += 1
end

p $doc_part_store
p JSON.pretty_generate(eval($doc_part_store[0][:response]["200"].join))
p $doc_part_store[0][:doc].join('\n')

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