require_relative 'response_handler.rb'

class Routes

	def initialize()
		@routes = []
  end
	
	def add_route(route, &block)
		regex_match = route.gsub(/\//, '\/').prepend('^').gsub(/:\w+/, '(\w+)')
		regex_capture = regex_match.gsub(/\w+(?!\+)/, '\w+')

		@routes.push({
			block: block,
			regex_capture: Regexp.new(regex_capture),
			regex_match: Regexp.new(regex_match)
			})
	end
	
	def route_exists(route)
		@routes.each { |route_properties| return true if route =~ route_properties[:regex_match] && route !~ /\./ }
		false
	end

	def send_response(session, route)
		resource = route_html(route)
		resource_length = resource.length
		headers = {'Content-Type': "text/html", 'Content-Length': resource_length.to_s}

		ResponseHandler.successful_response(session, resource, headers)
	end
	
	def route_html(route)
		@routes.each do |route_properties|
			if route =~ route_properties[:regex_match]
				params = route_properties[:regex_capture].match(route).captures
				return route_properties[:block].call(*params)
			end
		end
	end

end
