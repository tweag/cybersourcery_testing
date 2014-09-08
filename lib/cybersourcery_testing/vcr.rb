module CybersourceryTesting
  class Vcr
    def self.configure
      VCR.configure do |c|
        c.cassette_library_dir = 'spec/cassettes'
        c.hook_into :webmock
        c.allow_http_connections_when_no_cassette = true
        c.register_request_matcher :card_number_equality do |request_1, request_2|
          pattern = /\&card_number=(\d+)\&/i
          request_matcher_match?(pattern, request_1.body, request_2.body)
        end
      end
    end

    def self.request_matcher_match?(pattern, body1, body2)
      if body1 =~ pattern && body2 =~ pattern
        one = pattern.match(body1).captures[0]
        two = pattern.match(body2).captures[0]
        one == two
      else
        body1 !~ pattern && body2 !~ pattern
      end
    end
  end
end
