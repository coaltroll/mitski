require 'socket'
Dir[File.dirname(__FILE__) + '/*.rb'].each {|file| require file }

# contains the flow for the web server and interaction between the classes
class HTTPServer

	# initializes server with its port and routes attribute
  	#
  	# @param port [Integer] port where server is started
	# @return [HTTPServer] HTTPServer object
  	def initialize(port)
		@port = port

		@routes = Routes.new()
	end
	
	# runs server
  	def start
		server = TCPServer.new(@port)
		puts "Listening on #{@port}"

		while session = server.accept
			request = Request.new(session)

			route = @routes.find_route(request.resource)

			if route
				@routes.send_response(session, route, request.resource)
			else
				ResponseHandler.send_response(session, request)
			end

		end
	end

	# adds a route
  	#
  	# @param path [String] route, example: /staticPart/:param/staticPart2
	# @return [Array] returns routes attribute from @routes with route hashes which contain information about the routes
	def get(path, &block)
		@routes.add_route(path, &block)
	end
end
