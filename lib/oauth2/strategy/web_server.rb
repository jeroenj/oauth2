require 'yajl'

module OAuth2
  module Strategy
    class WebServer < Base
      def authorize_params(options = {}) #:nodoc:
        super(options).merge('type' => 'web_server')
      end

      # Retrieve an access token given the specified validation code.
      # Note that you must also provide a <tt>:redirect_uri</tt> option
      # in order to successfully verify your request for most OAuth 2.0
      # endpoints.
      def get_access_token(code, options = {})
        response = @client.request(:post, @client.access_token_url, access_token_params(code, options))
        parse_response(response)
      end

      def refresh_access_token(refresh_token, options = {})
        response = @client.request(:post, @client.access_token_url, refresh_token_params(refresh_token, options))
        parse_response(response)
      end

      # <b>DEPRECATED:</b> Use #get_access_token instead.
      def access_token(*args)
        warn '[DEPRECATED] OAuth2::Strategy::WebServer#access_token is deprecated, use #get_access_token instead. Will be removed in 0.1.0'
        get_access_token(*args)
      end

      def access_token_params(code, options = {}) #:nodoc:
        super(options).merge({
          :grant_type => 'authorization_code',
          :code => code
        })
      end

      def refresh_token_params(refresh_token, options = {}) #:nodoc:
        super(options).merge({
          :grant_type => 'refresh_token',
          :refresh_token => refresh_token
        })
      end

      def parse_response(response)
        params     = Yajl::Parser.parse(response) rescue Rack::Utils.parse_query(response)
        access     = params['access_token']
        expires_in = params['expires_in']
        refresh    = params['refresh_token']
        OAuth2::AccessToken.new(@client, access, refresh)        
      end
    end
  end
end
