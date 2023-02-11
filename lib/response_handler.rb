# Hugo approved 2023-02-07

require 'mime/types'
require 'socket'

class ResponseHandler

    NO_FILE_ERROR = Errno::ENOENT.freeze
	IS_A_DIRECTORY = Errno::EISDIR.freeze
    @resource_directory = "resources"
    
    def self.send_response(session, request)
        resource_output = resource_handler(request)

        if resource_output.is_a? Integer # resource_output is an error code
            error_response(session, request['resource'], resource_output)
        
        else # resource_output is a {resource: resource_string, headers: headers_hash}
            successful_response(session, resource_output[:resource], resource_output[:headers])
        end
    end

    def self.resource_handler(request)

        # access resource/file
        resource_filename = request["resource"]
        resource_path = @resource_directory + resource_filename

        mime = MIME::Types.type_for(resource_path).first
        if mime == nil
            mime = MIME::Types['application/octet-stream'].first
        end

        begin # attempt to open file

            if mime.binary?
                resource_file = File.open(resource_path, "rb")
            else
                resource_file = File.open(resource_path, "r")
            end

        rescue NO_FILE_ERROR, IS_A_DIRECTORY => e # error 404
            return 404
        end

        # resource
        resource_plaintext = resource_file.read

        # headers
        headers = {
            'content_length': resource_file.size.to_s,
            'content_type': mime.to_s
        }

        resource_file.close

        return {resource: resource_plaintext, headers: headers}
    end

    # Status code 200
    def self.successful_response(session, resource, headers)
        session.print "HTTP/1.1 200\r\n"
        session.print "Content-Type: text/html; charset=\r\n"
        
        headers.each do |header_type, header_value|
            session.print header_type.to_s + ": " + header_value + "\r\n"
        end

        session.print "\r\n"
        session.print resource
        session.close
    end

    # Errors
    def self.error_response(session, resource_name, error_code)
        session.print "HTTP/1.1 #{error_code}\r\n"
        session.print "Content-Type: text/html\r\n"
        session.print "\r\n"
        session.print "<h1> error #{error_code} </h1> \n<p> error accessing resource: \"#{resource_name}\" </p>"
        session.close
    end
end
