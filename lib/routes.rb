# frozen_string_literal: true

require_relative 'response_handler'

# Stores routes, checks if a route exists, and sends a response given a resource and route information hash
class Routes
  # Creates Routes object and initializes @routes attribute
  # @return [Routes] Routes object
  def initialize
    @routes = []
  end

  # Adds a route to the @routes attribute
  # @return [Array] the array of route hashes which contain information about the routes
  def add_route(route, &block)
    regex_match = route # example: "/posts/:name/smoothie/banana"
                  .gsub(%r{/}, '\/') #=> "\/posts\/:name\/smoothie\/banana"
                  .prepend('^') #=> "^\/posts\/:name\/smoothie\/banana"
                  .gsub(/:\w+/, '(\w+)') #=> "^\/posts\/(\w+)\/smoothie\/(\w+)"

    @routes.push({
                   block: block,
                   regex_match: Regexp.new(regex_match)
                 })
  end

  # Iterates @routes and finds route information that matches with requested resource
  # @param resource [string] the resource that is being attempted to access
  # @return [Hash, nil] the hash with route information if route is found, nil otherwise
  def find_route(resource)
    @routes.find do |route_properties|
      resource =~ route_properties[:regex_match] && # check if regex matches with resource
        resource !~ /\./ # TODO: what was this for? is it needed?
    end
  end

  # Sends a response given route information and resource
  # @param session [TCPSocket] the object needed to send back a response
  # @param route [Hash] the route information hash (from @routes attribute)
  # @param resource [String] the requested resource/route which contains params (URL in browser / route)
  # @return [void]
  def send_response(session, route, resource)
    params = route[:regex_match].match(resource).captures
    content = route[:block].call(*params)
    content_length = content.length
    headers = { 'Content-Type': 'text/html', 'Content-Length': content_length.to_s }

    ResponseHandler.successful_response(session, content, headers)
  end
end
