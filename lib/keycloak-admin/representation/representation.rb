require "json"
require_relative "camel_json"

class Representation
  include ::KeycloakAdmin::CamelJson

  def to_json(options=nil)
    snaked_hash = as_json
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
