require 'socket'
require 'pp'
require_relative 'lib/request_handler.rb'

class HTTPServer

	NO_FILE_ERROR = Errno::ENOENT.freeze

	def initialize(port)
		@port = port
	end

	def error_404(resource, session)
		session.print "HTTP/1.1 404\r\n"
		session.print "Content-Type: text/html\r\n"
		session.print "\r\n"
		session.print "<h1> error 404 </h1> \n<p> resource: \"#{resource}\" does not exist. </p>"
		session.close
	end

	def start
		server = TCPServer.new(@port)
		puts "Listening on #{@port}"

		while session = server.accept
			data = ""

			while line = session.gets and line !~ /^\s*$/
				data += line
			end
			
			puts "RECEIVED REQUEST"
			puts "-" * 40
			puts data
			puts "-" * 40 

			# parse http request
			request = RequestHandler.parse_request(data)
			
			# access resource/file
			resource_request = request["resource"]
			resource_path = "html" + resource_request

			begin # attempt to open file
				resource_file = File.open(resource_path, "r")

			rescue NO_FILE_ERROR => exception # error 404
				session.print "HTTP/1.1 404\r\n"
				session.print "Content-Type: text/html\r\n"
				session.print "\r\n"
				session.print "<h1> error 404 </h1> \n<p> resource: \"#{resource_request}\" does not exist. </p>"
				session.close
				next

			end
			
			resource_plaintext = resource_file.read
			resource_file.close
			

			resource_extension = resource_request.split(".").last

			if resource_extension == "html"
				html = resource_plaintext

				session.print "HTTP/1.1 200\r\n"
				session.print "Content-Type: text/html\r\n"
				session.print "\r\n"
				session.print html
				session.close
			else
				session.print "HTTP/1.1 420\r\n"
				session.print "Content-Type: text/html\r\n"
				session.print "\r\n"
				session.print "<p> Mitski only supports HTML </p>"
				session.close
			end
		end
	end
end

server = HTTPServer.new(4567)
server.start
