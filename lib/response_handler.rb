require 'mime/types'
require 'socket'

# has class methods used for finding resource files and sending responses
class ResponseHandler

	# Errno error code for "no file found"
	NO_FILE_ERROR = Errno::ENOENT.freeze
	# Errno error code for "is a directory"
	IS_A_DIRECTORY = Errno::EISDIR.freeze
	# directory (from app.rb) where all the resources are
	RESOURCE_DIRECTORY = "resources".freeze
	
	# takes in Request object and sends a response depending on the object's attributes 
  #
  # @param session [TCPSocket] socket session
	# @param request [Request] Request object 
  # @return [void]
	def self.send_response(session, request)
		content = parse_response(request)

		if content.is_a? Integer # content is an error code
			error_response(session, request.resource, content)
		
		else # content is a {content: content_string, headers: headers_hash}
			successful_response(session, content[:content], content[:headers])
		end
	end

	# takes in content of resource file, headers, and sends an html response
  #
  # @param session [TCPSocket] socket session
	# @param content [String] plaintext contents of resource file in String format
	# @param headers [Hash] {header-name1: "header value", header-name2: "...", ...}
  # @return [void]
	def self.successful_response(session, content, headers)
		session.print "HTTP/1.1 200\r\n"
		
		headers.each do |header_type, header_value|
			session.print header_type.to_s + ": " + header_value + "\r\n"
		end

		session.print "\r\n"
		session.print content
		session.close
	end

	# takes in resource (from request), error code, and sends an html response telling the user there has been an error an what error it is
  #
  # @param session [TCPSocket] socket session
	# @param resource [String] the same name of resource that is written in Request
	# @param error_code [Integer] error code
  # @return [void]
	def self.error_response(session, resource, error_code)
		session.print "HTTP/1.1 #{error_code}\r\n"
		session.print "Content-Type: text/html\r\n"
		session.print "\r\n"
		session.print "<h1> error #{error_code} </h1> \n<p> error accessing resource: \"#{resource}\" </p>"
		session.close
	end
	
	private
		# takes Request object 
		#
		# @param request [Request] Request object used for creating headers and accessing resource file
		# @return [Hash, Integer] Integer of error code if error, else: {content: "content of resource file as String", headers: {'content-length': "length", 'content-type': "type"}}
		def self.parse_response(request)

			resource_path = RESOURCE_DIRECTORY + request.resource

			# find mime type of resource file
			mime_type = MIME::Types.type_for(resource_path).first
			if mime_type == nil
				mime_type = MIME::Types['application/octet-stream'].first
			end

			begin # attempt to open file

				if mime_type.binary?
					resource_file = File.open(resource_path, "rb")
				else
					resource_file = File.open(resource_path, "r")
				end

			rescue NO_FILE_ERROR, IS_A_DIRECTORY => e # error 404 
				return 404
			end

			content = resource_file.read

			headers = {
				'content_length': resource_file.size.to_s,
				'content_type': mime_type.to_s
			}

			resource_file.close

			{content: content, headers: headers}
		end
end
