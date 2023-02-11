require 'socket'
require_relative 'lib/request_handler.rb'
require_relative 'lib/response_handler.rb'

class HTTPServer

	def initialize(port)
		@port = port
	end
	
	def start
		server = TCPServer.new(@port)
		puts "Listening on #{@port}"

		while session = server.accept
			request = RequestHandler::get_request(session)

			ResponseHandler::send_response(session, request)
		end
	end
end

server = HTTPServer.new(4567)
server.start
