require "json"
require_relative "camel_json"

class Representation
  include ::KeycloakAdmin::CamelJson

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
end
