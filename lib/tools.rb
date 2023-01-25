require 'csv'

module Tools

    def headers(file, request)
        headers = {}
        
        # Content-Length
        content_length = resource_file.size.to_s
		headers.merge!('Content-Length'=> content_length)

        # Content-Type
        file_extension = File.extname(file.path)
        if file_extension == nil
            content_type = "application/octet-stream"
        else
            CSV.foreach("lib/extension_to_mime.csv", headers: true) do |row|
                
            end

        content_type
    end

    module Status
        # Success
        def self.status_200(session, html, headers)
            session.print "HTTP/1.1 200\r\n"
            session.print "Content-Type: text/html; charset=\r\n"
            
            headers.each do |id, value|
                session.print id + ": " + value + "\r\n"
            end

            session.print "\r\n"
            session.print html
            session.close
        end

        # Errors
        def self.status_404(session, resource)
            session.print "HTTP/1.1 404\r\n"
            session.print "Content-Type: text/html\r\n"
            session.print "\r\n"
            session.print "<h1> error 404 </h1> \n<p> resource: \"#{resource}\" does not exist. </p>"
            session.close
        end

        def self.status_403(session)
            session.print "HTTP/1.1 403\r\n"
            session.print "Content-Type: text/html\r\n"
            session.print "\r\n"
            session.print "<p> Mitski only supports HTML </p>"
            session.close
        end
    end

end