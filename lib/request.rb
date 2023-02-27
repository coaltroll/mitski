require 'socket'
require 'pp'

class Request

	attr_reader :verb, :resource, :version, :headers

	def initialize(session)
		request_hash = get_request(session)

		@verb = request_hash['verb']
		@resource = request_hash['resource']
		@version = request_hash['version']
		@headers = request_hash['headers']
	end

	def method_missing(method_name)
		method_name = method_name.to_s.gsub(/[_]/, "-").to_sym

		@headers[method_name]
	end

	def print_request
		pp @data
	end

	private
		# reads raw request and returns parsed request as hash
		def get_request(session)
			@data = "" # dont make global, "REMOVE"

			while line = session.gets and line !~ /^\s*$/ # line != blank
				@data += line
			end

			# parse and return http request
			parse_request(@data) # => {'verb' => verb, 'resource' => resource, 'version' => version, 'headers' => {...}}
		end

		# parsed raw request string into hash with verb, resource, version, and headers hash 
		def parse_request(request)
			first_line = request.split("\n").first.split(" ")
			
			headers = request.split("\n"). # get rows
				drop(1). # remove request line
				map { |row| row.split(": ") }. # 2d arr [[header_1, header_value_1], [header_2...], ...]
				to_h. # hash {header_1: header_value_1, ...}
				map { |key, value| value.include?(", ") ? [key, value.split(", ")] : [key, value] } # if header value has multiple choices/values, make array

			parsed_request = { 'verb' => first_line[0], 'resource' => first_line[1], 'version'=> first_line[2], 'headers'=> headers }
		end
end
