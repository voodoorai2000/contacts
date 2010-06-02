module Contacts
  class Consumer
    #
    # Configure this consumer from the given hash.
    #
    def self.configure(configuration)
      @configuration = Util.symbolize_keys(configuration)
    end

    #
    # The configuration for this consumer.
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
    #     class MyConsumer < Consumer
    #       configuration_attribute :app_id
    #     end
    #
    #     MyConsumer.configure(:app_id => 'foo')
    #     consumer = MyConsumer.new
    #     consumer.app_id    # "foo"
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
      consumer = new
      consumer.initialize_serialized(data) if data
      consumer
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
        params[CGI.unescape(key)] = value ? CGI.unescape(value) : ''
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
