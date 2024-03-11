require "json"
require_relative "camel_json"

module KeycloakAdmin
  class Representation
    include CamelJson

    def as_json(options=nil)
      Hash[instance_variables.map { |ivar| [ivar.to_s[1..-1], instance_variable_get(ivar)] }]
    end

    def to_json(options=nil)
      snaked_hash = as_json(options)
      snaked_hash.keys.reduce({}) do |camelized_hash, key|
        camelized_hash[camelize(key, false)] = snaked_hash[key]
        camelized_hash
      end.to_json(options)
    end

    def self.from_json(json)
      hash = JSON.parse(json)
      from_hash(hash)
    end

    def self.snaked_to_camelized(snaked_hash)
      snaked_hash.deep_transform_keys! { |key| key.to_s.camelize(:lower) }
    end
  end
end
