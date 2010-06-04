module Contacts
  class Google < OAuthConsumer
    CONSUMER_OPTIONS = Util.frozen_hash(
      :site => "https://www.google.com",
      :request_token_path => "/accounts/OAuthGetRequestToken",
      :access_token_path => "/accounts/OAuthGetAccessToken",
      :authorize_path => "/accounts/OAuthAuthorizeToken"
    )

    REQUEST_TOKEN_PARAMS = Util.frozen_hash(
      'scope' => "https://www.google.com/m8/feeds/"
    )

    def initialize(options={})
      super(CONSUMER_OPTIONS, REQUEST_TOKEN_PARAMS)
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
