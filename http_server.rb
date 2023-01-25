require 'socket'
require 'pp'
require_relative 'lib/request_handler.rb'
require_relative 'lib/tools.rb'

class HTTPServer

	NO_FILE_ERROR = Errno::ENOENT.freeze
	IS_A_DIRECTORY = Errno::EISDIR.freeze

	def initialize(port)
		@port = port
		@resource_directory = "html"
	end

	
	def start
		server = TCPServer.new(@port)
		puts "Listening on #{@port}"

		while session = server.accept
			data = ""

			while line = session.gets and line !~ /^\s*$/ # line != blank
				data += line
			end
			
			puts "RECEIVED REQUEST"
			puts "-" * 40
			puts data
			puts "-" * 40 

			# parse http request
			request = RequestHandler.parse_request(data) # => {'verb' => verb, 'resource' => resource, 'version' => version, 'headers' => {...}}
			
			# access resource/file
			resource_filename = request["resource"]
			resource_path = @resource_directory + resource_filename


			begin # attempt to open file
				resource_file = File.open(resource_path, "r")

			rescue NO_FILE_ERROR, IS_A_DIRECTORY => e # error 404
				Tools::Status::status_404(session, request_resource)
				next

			end

			# headers
			headers = Tools::headers(file, request)

			# resource
			resource_plaintext = resource_file.read
			resource_file.close
			
			# resource extension
			resource_extension = request_resource.split(".").last

			if resource_extension == "html"
				Tools::Status::status_200(session, resource_plaintext, headers)
			else # resource filetype not supported
				Tools::Status::status_403(session)
			end
		end
	end
end

server = HTTPServer.new(4567)
server.start
