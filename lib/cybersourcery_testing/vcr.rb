module CybersourceryTesting
  class Vcr
    def self.configure
      VCR.configure do |c|
        c.cassette_library_dir = ENV['CYBERSOURCERY_VCR_CASSETTE_DIR']
        c.hook_into :webmock
        c.allow_http_connections_when_no_cassette = true
        c.register_request_matcher :card_number_equality do |request_1, request_2|
          pattern = /\&card_number=(\d+)\&/i
          self.did_it_change?(pattern, request_1.body, request_2.body)
        end
      end
    end

    def self.did_it_change?(pattern, body1, body2)
      if body1 =~ pattern && body2 =~ pattern
        one = pattern.match(body1).captures[0]
        two = pattern.match(body2).captures[0]
        one == two
      else
        body1 !~ pattern && body2 !~ pattern
      end
    end

    def self.match_requests_on
      exclude = %i(body headers host path query body_as_json)
      # @registry is private, but we really need it: all your encapsulation are belong to us
      all = VCR.request_matchers.instance_variable_get(:@registry).keys
      all - exclude # :method, :uri, and any custom matchers
    end
  end
end
