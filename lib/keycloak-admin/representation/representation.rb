# frozen_string_literal: true
require "json"
require_relative "camel_json"

class Representation
  include ::KeycloakAdmin::CamelJson

  def as_json(options=nil)
    instance_variables.each_with_object({}) do |ivar, hash|
      val = instance_variable_get(ivar)
      hash[ivar.to_s[1..-1]] = val unless val.nil?
    end
  end

  def to_json(options=nil)
    as_json(options).each_with_object({}) do |(key, val), hash|
      hash[camelize(key, false)] = val
    end.to_json(options)
  end

  def self.from_json(json)
    hash = JSON.parse(json)
    from_hash(hash)
  end
end
