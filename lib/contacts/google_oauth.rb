module Contacts
  class GoogleOAuth < Service
    CONSUMER_OPTIONS = Util.frozen_hash(
      :site => "https://www.google.com",
      :request_token_path => "/accounts/OAuthGetRequestToken",
      :access_token_path => "/accounts/OAuthGetAccessToken",
      :authorize_path => "/accounts/OAuthAuthorizeToken"
    )

    AUTHENTICATION_URL_PARAMS = Util.frozen_hash(
      'scope' => "https://www.google.com/m8/feeds/"
    )

    def self.configure(configuration)
      @consumer_key = configuration[:consumer_key]
      @consumer_secret = configuration[:consumer_secret]
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
      @request_token = consumer.get_request_token({}, AUTHENTICATION_URL_PARAMS)
      @request_token.authorize_url(:oauth_callback => target)
    end

    def authorize(params)
      begin
        @access_token = @request_token.get_access_token
      rescue OAuth::Unauthorized => error
        @error = error.message
      end
    end

    def contacts(options={})
      params = {:limit => 200}.update(options)
      google_params = translate_parameters(params)
      query = params_to_query(google_params)
      response = @access_token.get("/m8/feeds/contacts/default/thin?#{query}")
      parse_contacts(response.body)
    end

    def serialize
      params = {}
      params['access_token'] = serialize_oauth_token(@access_token) if @access_token
      params['request_token'] = serialize_oauth_token(@request_token) if @request_token
      params_to_query(params)
    end

    private

    class << self
      attr_reader :consumer_key
      attr_reader :consumer_secret
    end

    def consumer
      @consumer ||= OAuth::Consumer.new(self.class.consumer_key, self.class.consumer_secret, CONSUMER_OPTIONS)
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

    def translate_parameters(params)
      params.inject({}) do |all, pair|
        key, value = pair
        unless value.nil?
          key = case key
                when :limit
                  'max-results'
                when :offset
                  value = value.to_i + 1
                  'start-index'
                when :order
                  all['sortorder'] = 'descending' if params[:descending].nil?
                  'orderby'
                when :descending
                  value = value ? 'descending' : 'ascending'
                  'sortorder'
                when :updated_after
                  value = value.strftime("%Y-%m-%dT%H:%M:%S%Z") if value.respond_to? :strftime
                  'updated-min'
                else key
                end

          all[key] = value
        end
        all
      end
    end

    def parse_contacts(body)
      # TODO: use libxml
      doc = Hpricot::XML body
      contacts_found = []

      if updated_node = doc.at('/feed/updated')
        @updated_string = updated_node.inner_text
      end

      (doc / '/feed/entry').each do |entry|
        email_nodes = entry / 'gd:email[@address]'

        unless email_nodes.empty?
          title_node = entry.at('/title')
          name = title_node ? title_node.inner_text : nil
          contact = Contact.new(nil, name)
          contact.emails.concat email_nodes.map { |e| e['address'].to_s }
          contacts_found << contact
        end
      end

      contacts_found
    end
  end
end
