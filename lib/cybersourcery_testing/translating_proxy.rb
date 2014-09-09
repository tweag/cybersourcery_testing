require 'rack/translating_proxy'

module CybersourceryTesting
  class TranslatingProxy < Rack::TranslatingProxy
    def initialize(opts={})
      @translating_proxy = opts.fetch(:translating_proxy, 'http://localhost:5555')
      @silent_post_server = opts.fetch(:silent_post_server, 'https://testsecureacceptance.cybersource.com')
      @target_host = opts.fetch(:target_host, 'http://localhost:5556')
      @response_page_url = opts.fetch(:response_page_url, nil)
      @local_response_page_url = opts.fetch(:local_response_page_url, nil)
      super(opts)
    end

    def target_host
      @target_host
    end

    def request_mapping
      {
        # the proxy                what the target host thinks it is
        @translating_proxy => @silent_post_server,


        # local confirmation page          page where Cybersource redirects
        @local_response_page_url => @response_page_url
        # Using the IP address is important here, instead of localhost. The test server runs on
        # 127.0.0.1, and the app sets a cookie which is checked on /confirm. We need the IP address
        # to be the same, so the cookie is accessible (fortunately the port number doesn't matter)
      }
    end
  end
end
