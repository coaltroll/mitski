require_relative 'response_handler.rb'

# stores routes, checks if a route exists, and sends a response given a resource and route information hash
class Routes

	# creates Routes object and initializes @routes attribute
  #
  # @return [Routes] Routes object
	def initialize()
		@routes = []
  end
	
	# adds a route into the @routes attribute which can then be used through the class methods
  #
  # @return [Array] returns @routes attribute with route hashes which contain information about the routes
	def add_route(route, &block)

		route = ""

		regex_match = route.gsub(/\//, '\/').prepend('^').gsub(/:\w+/, '(\w+)')
		
		@routes.push({
			block: block,
			regex_match: Regexp.new(regex_match)
			})
	end
	
	# iterates @routes and finds route information that matches with requested resource
  #
	# @param route [Hash] route information hash (from @routes attribute)
  # @return [Hash, nil] returns hash with route information if route is found, nil otherwise
	def find_route(resource)
		@routes.find { |route_properties| resource =~ route_properties[:regex_match] && resource !~ /\./ }
	end

	# takes route information, resource from request, and sends a response
  #
	# @param session [TCPSocket] socket session
	# @param route [Hash] route information hash (from @routes attribute)
	# @param resource [String] requested resource/route which contains params (URL in browser / route)
  # @return [void]
	def send_response(session, route, resource)
		params = route[:regex_match].match(resource).captures
		content = route[:block].call(*params)
		content_length = content.length
		headers = {'Content-Type': "text/html", 'Content-Length': content_length.to_s}

		ResponseHandler.successful_response(session, content, headers)
	end

end
