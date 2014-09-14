require 'rack/translating_proxy'

module CybersourceryTesting
  class TranslatingProxy < Rack::TranslatingProxy
    def initialize(app)
      @app = app
    end

    def call(env)
      if proxy?(env)
        # TODO: see if there is a better way to do this.
        #
        # We need the HTTP_REFERER so we can keep track of the test server port, which is randomized
        # by Selenium, as we need to return to the test server when we're done with the transaction.
        #
        # Conceptually, http_referrer should be part of env, but env is not an instance variable.
        # We would have to rewrite multiple method signatures and a bunch of calls in the parent
        # translating_proxy.rb if we put the referrer in env (we need it in request_mapping(), which
        # is at the end of a chain of calls). Or rewrite the parent and grandparent classes to make
        # env an instance variable.
        #
        # The grandparent perform_request() (invoked by call()) already does a ton of stuff. Ideally
        # setting @referrer would be more isolated, but I don't see a reasonably quick way to
        # disentangle the dependencies. ...So what I'm doing here seems like the least painful
        # solution for now.
        source_request = Rack::Request.new env
        @referrer = source_request.referrer ? URI(source_request.referrer) : nil

        # TODO: this *almost* works properly
        #
        # VCR will work fine on the first test run. But then the Sinatra server gets into a
        # strange state. Subsequent test runs will hang, and canceling Sinatra isn't sufficient to
        # stop it (you need to enter an explicit kill command). I've tried overriding methods in the
        # related gems that cache various values, but that doesn't seem to be the problem.
        if ENV['CYBERSOURCERY_USE_VCR_IN_TESTS']
          VCR.use_cassette(
            'cybersourcery',
            record: :new_episodes,
            match_requests_on: CybersourceryTesting::Vcr.match_requests_on
          ) do
            super(env)
          end
        else
          super(env)
        end
      else
        @app.call(env)
      end
    end

    def proxy?(env)
      # The browser keeps requesting favicon.ico, which throws errors when the request is forwarded
      # to the Cybersource server. So ony forward POST requests.
      env['REQUEST_METHOD'] == 'POST'
    end

    def target_host
      ENV['CYBERSOURCERY_SOP_TEST_URL']
    end

    def request_mapping
      mappings = {
        # our proxy                             the actual Cybersource test server
        ENV['CYBERSOURCERY_SOP_PROXY_URL'] => ENV['CYBERSOURCERY_SOP_TEST_URL'],
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
