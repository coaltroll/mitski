# frozen_string_literal: true

require_relative '../lib/request'
require_relative 'fake_tcp_socket'

request = <<~REQUEST
  GET /grill HTTP/1.1\r
  User-Agent: Mozilla/4.0 (compatible; MSIE5.01; Windows NT)\r
  Accept-Encoding: gzip, deflate\r
  Connection: Keep-Alive\r
REQUEST

describe Request do
  before do
    fake_session = FakeTCPSocket.new(request)
    @parsed_request = Request.new(fake_session)
  end

  describe 'Parsing Simple HTTP GET Request' do
    it 'extracts the HTTP verb' do
      _(@parsed_request.verb).must_equal 'GET'
    end

    it 'extracts the HTTP resource' do
      _(@parsed_request.resource).must_equal '/grill'
    end

    it 'extracts the HTTP version' do
      _(@parsed_request.version).must_equal 'HTTP/1.1'
    end

    it 'extracts the HTTP headers' do
      headers =  { 'User-Agent' => 'Mozilla/4.0 (compatible; MSIE5.01; Windows NT)',
                   'Accept-Encoding' => %w[gzip deflate], 'Connection' => 'Keep-Alive' }
      _(@parsed_request.headers).must_equal headers
    end
  end
end
