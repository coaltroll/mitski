# frozen_string_literal: true

require 'socket'

# Reads requests, parses them, and has attributes for reading information about request
class Request
  attr_reader :verb, :resource, :version, :headers

  # Returns Request object with verb, resource, version, and headers of HTTP request given a TCPSocket object
  # @param session [TCPSocket] the object used for retrieving raw request data (with gets method)
  # @return [Request] the request object
  def initialize(session)
    request = get_request(session)

    @verb = request['verb']
    @resource = request['resource']
    @version = request['version']
    @headers = request['headers']
  end

  # Returns contents of a given header
  # @param header_name [Symbol] the name of the header sought / missing method
  # @return [String, nil] the value of sought header in @headers or nil if not found
  def method_missing(header_name)
    method_name = header_name.to_s.gsub('_', '-').to_sym
    @headers[method_name]
  end

  def respond_to_missing?(header_name)
    method_name = header_name.to_s.gsub('_', '-').to_sym
    @headers[method_name] || super
  end

  private

  # Returns parsed request as hash given a TCPSocket object (which contains a request)
  # @param session [TCPSocket] the object used for retrieving raw request data (with gets method)
  # @return [String, nil] the parsed hash request with verb, resource, version, and headers
  def get_request(session)
    data = ''

    while ((line = session.gets)) && line !~ (/^\s*$/) # line != blank
      data += line
    end

    parse_request(data) # => {'verb' => verb, 'resource' => resource, 'version' => version, 'headers' => {...}}
  end

  # Returns request hash with verb, resource, version, and headers hash given raw request string
  # @param request [String] the raw request string
  # @return [Hash] the parsed request hash with verb, resource, version, and headers keys
  def parse_request(request)
    request_rows = request.split("\r\n")
    request_line = request_rows.first.split
    headers = parse_headers(request_rows)

    {
      'verb' => request_line[0],
      'resource' => request_line[1],
      'version' => request_line[2],
      'headers' => headers
    }
  end

  # Returns headers hash given array of lines/strings from request
  # @param request_rows [Array<String>] the array of lines/rows/strings from the request
  # @return [Hash] the parsed headers hash { header1: value1, header2: [value2_0, value2_1] }
  def parse_headers(request_rows)
    request_rows
      .drop(1) # remove request line
      .to_h do |row| # { header1: value1, header2: [value2_0, value2_1] }
        key, value = row.split(': ')
        if value.include?(', ')
          [key, value.split(', ')]
        else
          [key, value]
        end
      end
  end
end
