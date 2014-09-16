require 'rack/translating_proxy'

module CybersourceryTesting
  class TranslatingProxy < Rack::TranslatingProxy
    alias :super_call :call

    def initialize(app)
      @app = app
    end

    def call(env)
      if proxy?(env)
        request = Rack::Request.new(env)
        set_referrer(request)
        check_for_cryptic_cybersource_errors(request)
        maybe_use_vcr(env)
      else
        @app.call(env)
      end
    end

    def proxy?(env)
      # The browser keeps requesting favicon.ico, which throws errors when the request is forwarded
      # to the Cybersource server. So ony forward POST requests.
      env['REQUEST_METHOD'] == 'POST'
    end

    def set_referrer(request)
      # We are making @referrer an instance variable for convenience. We need it since the port of
      # the test server can change with every test run. Conceptually, http_referrer should be part
      # of env, but env is not an instance variable. We would have to rewrite multiple method
      # signatures and a bunch of calls in the parent translating_proxy.rb if we put the referrer in
      # env (we need it in request_mapping(), which is at the end of a chain of calls).
      @referrer = request.referrer ? URI(request.referrer) : nil
    end

    def check_for_cryptic_cybersource_errors(request)
      request.params.each do |k,v|
        if v.class != String
          raise "You are attempting to pass a value that is not a String to Cybersource. This will cause Cybersource to throw a generic server error. You passed: #{k}: #{v.to_s}"
        end

        if k == 'signed_field_names' && v.length >= 700
          raise "You are attempting to pass a signed_fields value to Cybersource that is 700 characters or greater. This will cause Cybersource to throw a generic server error. You passed: #{k}: #{v}"
        end
      end
    end

    def maybe_use_vcr(env)
      # TODO: This *almost* works properly. Using Shotgun lets us sidestep the problem.
      #
      # VCR will work fine on the first test run. But without Shotgun, then the Sinatra server gets
      # into a strange state. Subsequent test runs will hang, and canceling Sinatra isn't sufficient
      # to stop it (you need to enter an explicit kill command). This seems to have to do with
      # running VCR in the context of this middleware, which is not the environment for which it was
      # designed.
      if ENV['CYBERSOURCERY_USE_VCR_IN_TESTS']
        VCR.use_cassette(
          'cybersourcery',
          record: :new_episodes,
          match_requests_on: CybersourceryTesting::Vcr.match_requests_on
        ) do
          super_call(env)
        end
      else
        super_call(env)
      end
    end

    def target_host
      ENV['CYBERSOURCERY_SOP_TEST_URL']
    end

    def request_mapping
      mappings = {
        # our proxy                           the actual Cybersource test server
        ENV['CYBERSOURCERY_SOP_PROXY_URL'] => ENV['CYBERSOURCERY_SOP_TEST_URL'],
      }

      if @referrer
        local_response_url = "#{@referrer.scheme}://#{@referrer.host}:#{@referrer.port}#{ENV['CYBERSOURCERY_LOCAL_RESPONSE_PAGE_PATH']}"

        #        local resp page       page where Cybersource redirects
        mappings[local_response_url] = ENV['CYBERSOURCERY_RESPONSE_PAGE_URL']
      end

      mappings
    end

    # override parent
    def rewrite_response_body(body)
      # to_s on an array gives a version that has brackets, escape characters, etc. I don't know why
      # it worked outside the middleware context (as I didn't have this problem with it before).
      #str = rewrite_string(body.to_s, _response_mapping)
      str = rewrite_string(body.first, _response_mapping)
      rewrite_string(str, _response_mapping, URI.method(:encode_www_form_component))
    end

    # override parent - we need this refreshed with each request, since the test server port changes
    def _response_mapping
      request_mapping.invert
    end
  end
end
