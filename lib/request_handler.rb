require 'socket'

class RequestHandler

	def self.parse_request(request)
		first_line = request.split("\n").first.split(" ")
		
		headers = request.split("\n"). # get rows
			drop(1). # remove request line
			map { |row| row.split(": ") }. # 2d arr [[header_1, header_value_1], [header_2...], ...]
			to_h. # hash {header_1: header_value_1, ...}
			map { |key, value| value.include?(", ") ? [key, value.split(", ")] : [key, value] } # if header value has multiple choices/values, make array

		parsed_request = { 'verb' => first_line[0], 'resource' => first_line[1], 'version'=> first_line[2], 'headers'=> headers }
		
		return parsed_request
	end

	def self.get_request(session)
		data = ""

		while line = session.gets and line !~ /^\s*$/ # line != blank
			data += line
		end

		# parse and return http request
		return parse_request(data) # => {'verb' => verb, 'resource' => resource, 'version' => version, 'headers' => {...}}
	end
end
