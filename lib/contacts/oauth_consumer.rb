module Contacts
  class OAuthConsumer < Consumer
    configuration_attribute :consumer_key
    configuration_attribute :consumer_secret

    def initialize(consumer_options, request_token_params)
      @consumer_options = consumer_options
      @request_token_params = request_token_params
    end

    def initialize_serialized(data)
      params = query_to_params(data)
      value = params['request_token'] and
        @request_token = deserialize_oauth_token(consumer, value)
      value = params['access_token'] and
        @access_token = deserialize_oauth_token(consumer, value)
    end

    attr_accessor :request_token
    attr_accessor :access_token
    attr_accessor :error

    def authentication_url(target, options={})
      @request_token = consumer.get_request_token({:oauth_callback => target}, @request_token_params)
      @request_token.authorize_url
    end

    def authorize(params)
      begin
        @access_token = @request_token.get_access_token(:oauth_verifier => params['oauth_verifier'])
      rescue OAuth::Unauthorized => error
        @error = error.message
      end
    end

    private

    def consumer
      @consumer ||= OAuth::Consumer.new(consumer_key, consumer_secret, @consumer_options)
    end

    #
    # Marshal sucks for persistence. This provides a prettier, more
    # future-proof persistable representation of a token.
    #
    def serialize_oauth_token(token)
      params = {
        'version' => '1',  # serialization format
        'type' => token.is_a?(OAuth::AccessToken) ? 'access' : 'request',
        'oauth_token' => token.token,
        'oauth_token_secret' => token.secret,
      }
      params_to_query(params)
    end

    def deserialize_oauth_token(consumer, data)
      params = query_to_params(data)
      klass = params['type'] == 'access' ? OAuth::AccessToken : OAuth::RequestToken
      token = klass.new(consumer, params.delete('oauth_token'), params.delete('oauth_token_secret'))
      token
    end
  end
end
