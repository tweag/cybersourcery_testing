require 'rack/translating_proxy'

module CybersourceryTesting
  class TranslatingProxy < Rack::TranslatingProxy
    # def initialize(opts={})
    #   @translating_proxy = opts.fetch(:translating_proxy, 'http://localhost:5555')
    #   @silent_post_server = opts.fetch(:silent_post_server, 'https://testsecureacceptance.cybersource.com')
    #   @target_host = opts.fetch(:target_host, 'http://localhost:5556')
    #   @response_page_url = opts.fetch(:response_page_url, nil)
    #   @local_response_page_url = opts.fetch(:local_response_page_url, nil)
    #   super(opts)
    # end

    def target_host
      'http://localhost:5556'
    end

    def request_mapping
      {
        # the proxy                what the target host thinks it is
        'http://localhost:5555' => 'https://testsecureacceptance.cybersource.com',


        # local confirmation page          page where Cybersource redirects
        'http://127.0.0.1:3000/confirm' => 'http://tranquil-ocean-5865.herokuapp.com/confirm'
        # Using the IP address is important here, instead of localhost. The test server runs on
        # 127.0.0.1, and the app sets a cookie which is checked on /confirm. We need the IP address
        # to be the same, so the cookie is accessible (fortunately the port number doesn't matter)
      }
    end
  end
end
