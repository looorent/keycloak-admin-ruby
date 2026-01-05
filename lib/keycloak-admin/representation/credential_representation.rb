module KeycloakAdmin
  class CredentialRepresentation < Representation
    attr_accessor :id,
      :type,
      :userLabel,
      :device,
      :value,
      :hashedSaltedValue,
      :salt,
      :hashIterations,
      :counter,
      :algorithm,
      :digits,
      :period,
      :createdDate,
      :credentialData,
      :secretData,
      :config,
      :temporary

    def self.from_password(password, temporary=false)
      credential = new
      credential.value     = password
      credential.type      = "password"
      credential.temporary = temporary
      credential
    end

    def self.from_json(json)
      attributes = JSON.parse(json)
      from_hash(attributes)
    end

    def self.from_hash(hash)
      credential = new
      hash.each do |key, value|
        if credential.respond_to?("#{key}=")
          credential.public_send("#{key}=", value)
        end
      end

      nested_attributes = safely_parse_nested_json(hash["credentialData"]).merge(safely_parse_nested_json(hash["secretData"]))

      nested_attributes.each do |key, value|
        if credential.respond_to?("#{key}=")
          current_value = credential.public_send(key)
          if current_value.nil?
            credential.public_send("#{key}=", value)
          end
        end
      end

      credential
    end

    class << self
      private

      def safely_parse_nested_json(json_string)
        if json_string.nil? || json_string.strip.empty?
          {}
        else
          begin
            JSON.parse(json_string)
          rescue JSON::ParserError
            {}
          end
        end
      end
    end
  end
end