# frozen_string_literal: true

require 'mime/types'
require 'socket'

# Has class methods used for finding resource files and sending responses
class ResponseHandler
  # Errno error code for "no file found"
  NO_FILE_ERROR = Errno::ENOENT.freeze
  # Errno error code for "is a directory"
  IS_A_DIRECTORY = Errno::EISDIR.freeze
  # directory (from app.rb) where all the resources are
  RESOURCE_DIRECTORY = 'resources'

  # Sends a response given the object's attributes and a Request object
  # @param session [TCPSocket] the object needed to send back a response
  # @param request [Request] the Request object used for accessing request information
  # @return [void]
  def self.send_response(session, request)
    response_info = parse_response(request)

    if response_info.is_a? Integer # response_info is an error code
      error_response(session, request.resource, response_info)

    else # response_info is of type {body: body_string, headers: headers_hash}
      successful_response(session, response_info[:body], response_info[:headers])
    end
  end

  # Sends a response given a body and headers
  # @param session [TCPSocket] the object needed to send back a response
  # @param body [String] the body of the response in String format
  # @param headers [Hash] the headers to be sent in the response
  # @return [void]
  def self.successful_response(session, body, headers)
    session.print "HTTP/1.1 200\r\n"

    headers.each do |header_type, header_value|
      session.print "#{header_type}: #{header_value}\r\n"
    end

    session.print "\r\n"
    session.print body
    session.close
  end

  # Sends an html response with error message given a resource (from request) and an error code
  # @param session [TCPSocket] the object needed to send back a response
  # @param resource [String] the same name of resource that is written in Request
  # @param error_code [Integer] the error code
  # @return [void]
  def self.error_response(session, resource, error_code)
    session.print "HTTP/1.1 #{error_code}\r\n"
    session.print "Content-Type: text/html\r\n"
    session.print "\r\n"
    session.print "<h1> error #{error_code} </h1> \n<p> error accessing resource: \"#{resource}\" </p>"
    session.close
  end

  # Returns information needed for response given a Request object
  # @param request [Request] the Request object used for accessing request information
  # @return [Hash, Integer] the error code if error, else: hash with body and headers keys
  def self.parse_response(request)
    resource_path = RESOURCE_DIRECTORY + request.resource

    mime_type = mime_type(resource_path)

    resource_file = open_resource(resource_path, mime_type.binary?)

    return resource_file if resource_file.is_a? Integer # error

    body = resource_file.read

    headers = {
      content_length: resource_file.size.to_s,
      content_type: mime_type.to_s
    }

    resource_file.close

    { body: body, headers: headers }
  end

  # Returns MIME::TYPE given a resource_path string
  # @param resource_path [string] the path to the resource requested
  # @return [MIME::TYPE] the first MIME::TYPE that matches with resource extension, otherwise [application/octet-stream]
  def self.mime_type(resource_path)
    mime_type = MIME::Types.type_for(resource_path).first
    if mime_type.nil?
      MIME::Types['application/octet-stream'].first
    else
      mime_type
    end
  end

  # Returns a File with appropriate reading mode given a mime_type and resource_path. When error returns Integer 404
  # @param resource_path [string] the path to the resource requested
  # @param is_binary [boolean] the content type of the resource file
  # @return [File, Integer] the File object for the resource or Integer status code 404 if file is not found
  def self.open_resource(resource_path, is_binary)
    # attempt to open file
    begin
      resource_file = if is_binary
                        File.open(resource_path, 'rb')
                      else
                        resource_file = File.open(resource_path, 'r')
                      end
    rescue NO_FILE_ERROR, IS_A_DIRECTORY # error 404
      return 404
    end
    p resource_file
    resource_file
  end
end
