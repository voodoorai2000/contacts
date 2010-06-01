module Contacts
  module Util
    def self.frozen_hash(hash={})
      hash.freeze
      hash.keys.each{|k| k.freeze}
      hash.values.each{|v| v.freeze}
      hash
    end
  end
end
