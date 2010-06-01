require 'contacts/version'

module Contacts
  
  Identifier = 'Ruby Contacts v' + VERSION::STRING
  
  def self.configure(configuration)
    configuration.each do |key, value|
      klass =
        case key.to_s
        when 'google'
          GoogleOAuth
        when 'yahoo'
          YahooOAuth
        when 'windows_live'
          WindowsLive
        when 'flickr'
          Flickr
        else
          raise ArgumentError, "unknown service: #{key}"
        end
      klass.configure(value)
    end
  end

  # An object that represents a single contact
  class Contact
    attr_reader :name, :username, :emails
    
    def initialize(email, name = nil, username = nil)
      @emails = []
      @emails << email if email
      @name = name
      @username = username
    end
    
    def email
      @emails.first
    end
    
    def inspect
      %!#<Contacts::Contact "#{name}"#{email ? " (#{email})" : ''}>!
    end
  end
  
  def self.verbose?
    'irb' == $0
  end
  
  class Error < StandardError
  end
  
  class TooManyRedirects < Error
    attr_reader :response, :location
    
    MAX_REDIRECTS = 2
    
    def initialize(response)
      @response = response
      @location = @response['Location']
      super "exceeded maximum of #{MAX_REDIRECTS} redirects (Location: #{location})"
    end
  end

  autoload :Util, 'contacts/util'
  autoload :Service, 'contacts/service'
  autoload :OAuthService, 'contacts/oauth_service'
  autoload :Google, 'contacts/google'
  autoload :GoogleOAuth, 'contacts/google_oauth'
  autoload :Yahoo, 'contacts/yahoo'
  autoload :YahooOAuth, 'contacts/yahoo_oauth'
  autoload :WindowsLive, 'contacts/windows_live'
  autoload :Flickr, 'contacts/flickr'
end
