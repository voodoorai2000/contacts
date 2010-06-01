module Contacts
  class Service
    #
    # Configure this service from the given hash.
    #
    def self.configure(configuration)
      @configuration = Util.symbolize_keys(configuration)
    end

    #
    # The configuration for this service.
    #
    def self.configuration
      @configuration
    end

    #
    # Define an instance-level reader for the named configuration
    # attribute.
    #
    # Example:
    #
    #     class MyService < Service
    #       configuration_attribute :app_id
    #     end
    #
    #     MyService.configure(:app_id => 'foo')
    #     service = MyService.new
    #     service.app_id    # "foo"
    #
    def self.configuration_attribute(name)
      class_eval <<-EOS
        def #{name}
          self.class.configuration[:#{name}]
        end
      EOS
    end

    def initialize(options={})
    end

    def initialize_serialized(data)
      raise NotImplementedError, 'abstract'
    end

    def serialize
      raise NotImplementedError, 'abstract'
    end

    def self.deserialize(data)
      service = new
      service.initialize_serialized(data) if data
      service
    end

    protected

    def self.params_to_query(params)
      params.map do |key, value|
        "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
      end.join('&')
    end

    def self.query_to_params(data)
      params={}
      data.split(/&/).each do |pair|
        key, value = *pair.split(/=/)
        params[CGI.unescape(key)] = CGI.unescape(value)
      end
      params
    end

    def params_to_query(params)
      self.class.params_to_query(params)
    end

    def query_to_params(data)
      self.class.query_to_params(data)
    end
  end
end
