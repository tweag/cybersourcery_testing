require 'rack/translating_proxy'

module CybersourceryTesting
  class TranslatingProxyMiddleware < Rack::TranslatingProxy
    def initialize(app)
      @app = app
    end

    def call(env)
      source_request = Rack::Request.new env
      @referrer = source_request.referrer ? URI(source_request.referrer) : nil
      super(env)
    end

    def target_host
      ENV['CYBERSOURCERY_SOP_TEST_URL']
    end

    def request_mapping
      mappings = {
        # our proxy                             the actual Cybersource test server
        ENV['CYBERSOURCERY_TARGET_HOST_URL'] => ENV['CYBERSOURCERY_SOP_TEST_URL'],
      }

      if @referrer
        local_response_url = "#{@referrer.scheme}://#{@referrer.host}:#{@referrer.port}#{ENV['CYBERSOURCERY_LOCAL_RESPONSE_PAGE_PATH']}"

        #        local resp page       page where Cybersource redirects
        mappings[local_response_url] = ENV['CYBERSOURCERY_RESPONSE_PAGE_URL']
      end

      mappings
    end

    def rewrite_response_body(body)
      # to_s gives a version that has brackets, escape characters, etc. I don't know why it worked
      # outside the middleware context (as I didn't have a problem with it before)
      #str = rewrite_string(body.to_s, _response_mapping)
      str = rewrite_string(body.first, _response_mapping)
      rewrite_string(str, _response_mapping,
        URI.method(:encode_www_form_component))
    end

    # override parent - we need this refreshed with each request, since the test server port changes
    def _response_mapping
      request_mapping.invert
    end
  end
end
