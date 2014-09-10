require 'rack/translating_proxy'

module CybersourceryTesting
  class TranslatingProxy < Rack::TranslatingProxy
    def initialize(opts={})
      @translating_proxy = opts.fetch :translating_proxy
      @silent_post_server = opts.fetch :silent_post_server
      @target_host = opts.fetch :target_host
      @response_page_url = opts.fetch :response_page_url
      @local_response_page_path = opts.fetch :local_response_page_path
      super opts
    end

    # TODO: see if there is a better way to do this.
    #
    # Conceptually, http_referrer should be part of env, but env is not an instance variable.
    # We would have to rewrite multiple method signatures and a bunch of calls in the parent
    # translating_proxy.rb if we put the referrer in env (we need it in request_mapping(), which is
    # at the end of a chain of calls). Or rewrite the parent and grandparent classes to make env an
    # instance variable.
    #
    # The grandparent perform_request() (invoked by call()) already does a ton of stuff. Ideally
    # setting @referrer would be more isolated, but I don't see a reasonably quick way to
    # disentangle the dependencies. ...So what I'm doing here seems like the least painful solution
    # for now.
    def call(env)
      source_request = Rack::Request.new env
      @referrer = source_request.referrer ? URI(source_request.referrer) : nil
      super env
    end

    def target_host
      @target_host
    end

    def request_mapping
      mappings = {
        # our proxy           the actual Cybersource test server
        @translating_proxy => @silent_post_server
      }

      if @referrer
        local_response_url = "#{@referrer.scheme}://#{@referrer.host}:#{@referrer.port}#{@local_response_page_path}"

        #        local resp page       page where Cybersource redirects
        mappings[local_response_url] = @response_page_url
      end

      mappings
    end
  end
end
