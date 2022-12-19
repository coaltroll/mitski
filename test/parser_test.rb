require_relative '../lib/request_handler.rb'

describe RequestHandler do

  before do
    request = <<~END
    GET /grill HTTP/1.1
    User-Agent: Mozilla/4.0 (compatible; MSIE5.01; Windows NT)
    Host: www.tutorialspoint.com
    Accept-Language: en-us
    Accept-Encoding: gzip, deflate
    Connection: Keep-Alive
    END

    @parsed_request = RequestHandler::parse_request(request)
  end

  describe "Parsing Simple HTTP GET Request" do
    
    it "extracts the HTTP verb" do
      _(@parsed_request['verb']).must_equal "GET"
    end

    it "extracts the HTTP resource" do
      _(@parsed_request["resource"]).must_equal "/grill"
    end

    it "extracts the HTTP version" do
      _(@parsed_request["version"]).must_equal "HTTP/1.1"
    end
  end

 
end