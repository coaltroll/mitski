require 'socket'

# reads requests, parses them, and has attributes for reading information about request
class Request

	attr_reader :verb, :resource, :version, :headers

	# takes in request being sent to session and creates Request object with verb, resource, version, and headers of request 
  #
  # @param session [TCPSocket] socket session
  # @return [Request] request object
	def initialize(session)
		request_hash = get_request(session)
		
		@verb = request_hash['verb']
		@resource = request_hash['resource']
		@version = request_hash['version']
		@headers = request_hash['headers']
	end

	# finds header in resource and returns its contents
  #
  # @param header_name [Symbol] name of header/ missing method
  # @return [String, nil] the value of the header associated to header_name in @headers or nil if header does not exist in Request object
	def method_missing(header_name)
		method_name = header_name.to_s.gsub(/[_]/, "-").to_sym

		@headers[method_name]
	end


	private
		# reads raw request and returns parsed request as hash
		#
  	# @param session [TCPSocket] socket session
  	# @return [String, nil] parsed hash request with verb, resource, version, and headers
		def get_request(session)
			data = ""

			while line = session.gets and line !~ /^\s*$/ # line != blank
				data += line
			end

			parse_request(data) # => {'verb' => verb, 'resource' => resource, 'version' => version, 'headers' => {...}}
		end

		# parse raw request string into hash with verb, resource, version, and headers hash
		#
		# @param request [String] request string read from session
		# @return [Hash] parsed request hash in the form: {'verb' => verb, 'resource' => resource, 'version' => version, 'headers' => {...}}
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
