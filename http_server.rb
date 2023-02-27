require 'socket'
require_relative 'lib/request.rb'
require_relative 'lib/response_handler.rb'

class HTTPServer

	def initialize(port)
		@port = port
	end
	
	def start
		server = TCPServer.new(@port)
		puts "Listening on #{@port}"

		while session = server.accept
			request = Request.new(session)

			request.print_request()

			ResponseHandler.send_response(session, request)
		end
	end

	def gets(path, &block)

	end
end

server = HTTPServer.new(4567)

server.get('/banan/:id') do |id|

end

server.start
