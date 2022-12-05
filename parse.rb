require 'pp'

def parse_request(request_string)
    first_line = request_string.split("\n").first.split(" ")
    headers = request_string.split("\n").
        drop(1).
        map { |row| row.split(": ") }.
        to_h.
        map { |key, value| value.include?(", ") ? [key, value.split(", ")] : [key, value] }.
        to_h
    request = { 'verb': first_line[0], 'resource': first_line[1], 'headers': headers }

    return request
end

request_string = <<~END
GET /hello HTTP/1.1
User-Agent: Mozilla/4.0 (compatible; MSIE5.01; Windows NT)
Host: www.tutorialspoint.com
Accept-Language: en-us
Accept-Encoding: gzip, deflate
Connection: Keep-Alive
END

pp parse_request(request_string)
