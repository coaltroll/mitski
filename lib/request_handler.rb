require 'pp'

class RequestHandler

	def self.parse_request(request)
		first_line = request.split("\n").first.split(" ")
		
		headers = request.split("\n").
			drop(1).
			map { |row| row.split(": ") }.
			to_h.
			map { |key, value| value.include?(", ") ? [key, value.split(", ")] : [key, value] }.
			to_h

		parsed_request = { 'verb' => first_line[0], 'resource' => first_line[1], 'version'=> first_line[2], 'headers'=> headers }
		
		return parsed_request
	end
end


