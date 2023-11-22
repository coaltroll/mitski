# frozen_string_literal: true

require 'socket'
require_relative 'request'
require_relative 'response_handler'
require_relative 'routes'

# Contains logic for what to do when a request is recieved and an interface to add routes
class HTTPServer
  # Returns server given a port
  # @param port [Integer] the port where the server is started
  # @return [HTTPServer] the HTTPServer object
  def initialize(port)
    @port = port
    @routes = Routes.new
  end

  # Runs server
  def start
    server = TCPServer.new(@port)
    puts "Listening on #{@port}"

    while (session = server.accept)
      request = Request.new(session)
      route = @routes.find_route(request.resource)
      if route
        @routes.send_response(session, route, request.resource)
      else
        ResponseHandler.send_response(session, request)
      end
    end
  end

  # Adds a route
  # @param route [String] the route, example: "/staticPart/:param/staticPart2"
  # @return [Array] the array of route hashes which contain information about the routes
  def get(route, &block)
    @routes.add_route(route, &block)
  end
end
