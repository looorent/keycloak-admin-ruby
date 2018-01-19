module KeycloakAdmin
  class CredentialRepresentation < Representation
    attr_accessor :type,
      :device,
      :value,
      :hashedSaltedValue,
      :salt,
      :hashIterations,
      :counter,
      :algorithm,
      :digits,
      :period,
      :created_date,
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
        property = "@#{key}".to_sym
        credential.instance_variable_set(property, value)
      end
      credential
    end
  end
end