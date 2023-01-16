module Status

    # Success
    def self.status_200(session, html)
        session.print "HTTP/1.1 200\r\n"
        session.print "Content-Type: text/html\r\n"
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