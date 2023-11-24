# frozen_string_literal: true

class FakeTCPSocket
  attr_reader :response_printed

  def initialize(fake_request)
    @fake_request_arr = fake_request.scan(/[^\n]*\n/)
    @fake_request_index = 0
    @response_printed_arr = []
  end

  def gets
    request_line_read = @fake_request_arr[@fake_request_index]
    @fake_request_index += 1
    request_line_read
  end

  def print(line)
    @response_printed_arr.push(line)
  end

  def close
    @response_printed = @response_printed_arr.join
  end
end
