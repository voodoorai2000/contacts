module Contacts
  class Service
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
