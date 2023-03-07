require 'socket'
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

class HTTPServer

	def initialize(port)
		@port = port

		@routes = Routes.new()
	end
	
	def start
		server = TCPServer.new(@port)
		puts "Listening on #{@port}"

		while session = server.accept
			request = Request.new(session)

			if @routes.route_exists(request.resource)
				@routes.send_response(session, request.resource)
			else
				ResponseHandler.send_response(session, request)
			end

		end
	end

	def get(path, &block)
		@routes.add_route(path, &block)
	end
end
