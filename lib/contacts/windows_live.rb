require 'contacts'
require File.join(File.dirname(__FILE__), %w{.. .. vendor windowslivelogin})

require 'rubygems'
require 'hpricot'
require 'uri'
require 'yaml'

module Contacts
  class WindowsLive < Consumer
    configuration_attribute :application_id
    configuration_attribute :secret_key
    configuration_attribute :security_algorithm
    configuration_attribute :privacy_policy_url
    configuration_attribute :return_url

    #
    # If this is set, then #authentication_url will force the given
    # +target+ URL to have this origin (= scheme + host + port). This
    # should match the domain that your Windows Live project is
    # configured to live on.
    #
    # Instead of calling #authorize(params) when the user returns, you
    # will need to call #forced_redirect_url(params) to redirect the
    # user to the true contacts handler. #forced_redirect_url will
    # handle construction of the query string based on the incoming
    # parameters.
    #
    # The intended use is for development mode on localhost, which
    # Windows Live forbids redirection to. Instead, you may register
    # your app to live on "http://myapp.local", set :force_origin =>
    # 'http://myapp.local:3000', and map the domain to 127.0.0.1 via
    # your local hosts file. Your handlers will then look something
    # like:
    #
    #     def handler
    #       if ENV['HTTP_METHOD'] == 'POST'
    #         consumer = Contacts::WindowsLive.new
    #         redirect_to consumer.authentication_url(session)
    #       else
    #         consumer = Contacts::WindowsLive.deserialize(session[:consumer])
    #         consumer.authorize(params)
    #         contacts = consumer.contacts
    #       end
    #     end
    #
    # Since only the origin is forced -- not the path part of the URL
    # -- the handler typically redirects to itself. The second time
    # through it is a GET request.
    #
    # Default: nil
    #
    # Example: http://myapp.local
    #
    configuration_attribute :force_origin

    def initialize(options={})
      @wll = WindowsLiveLogin.new(application_id, secret_key, security_algorithm, nil, privacy_policy_url, return_url)
      @consent = {}
    end

    def initialize_serialized(data)
      params = query_to_params(data)
      @consent = params['consent']
    end

    def serialize
      params_to_query('consent' => @consent)
    end

    def authentication_url(target, options={})
      if force_origin
        context = target
        target = force_origin + URI.parse(target).path
      end
      @wll.getConsentUrl("Contacts.Invite", context, target)
    end

    def forced_redirect_url(params)
      target_origin = params['appctx'] and
        "#{target_origin}?#{params_to_query(params)}"
    end

    def authorize(params)
      @consent = params['ConsentToken']
    end

    def contacts(options={})
      # TODO: support standard Contacts options.
      consent_token = @wll.processConsentToken(@consent, nil)
      contacts_xml = access_live_contacts_api(consent_token)
      contacts_list = WindowsLive.parse_xml(contacts_xml)
    end

    private

    def access_live_contacts_api(consent_token)
      http = http = Net::HTTP.new('livecontacts.services.live.com', 443)
      http.use_ssl = true

      response = nil
      http.start do |http|
         request = Net::HTTP::Get.new("/users/@L@#{consent_token.locationid}/rest/invitationsbyemail", {"Authorization" => "DelegatedToken dt=\"#{consent_token.delegationtoken}\""})
         response = http.request(request)
      end

      return response.body
    end

    def self.parse_xml(xml)
      doc = Hpricot::XML(xml)

      contacts = []
      doc.search('/livecontacts/contacts/contact').each do |contact|
        email = contact.at('/preferredemail').inner_text
        email.strip!

        first_name = last_name = nil
        if first_name = contact.at('/profiles/personal/firstname')
          first_name = first_name.inner_text.strip
        end

        if last_name = contact.at('/profiles/personal/lastname')
          last_name = last_name.inner_text.strip
        end
        
        name = nil
        if !first_name.nil? || !last_name.nil?
          name = "#{first_name} #{last_name}"
          name.strip!
        end
        new_contact = Contact.new(email, name)
        contacts << new_contact
      end

      return contacts
    end
  end
end
