module KeycloakAdmin
  class AttackDetectionRepresentation < Representation
    attr_accessor :num_failures,
      :disabled,
      :last_ip_failure,
      :last_failure

    def self.from_hash(hash)
      rep                 = new
      rep.num_failures    = hash['numFailures']
      rep.disabled        = hash['disabled']
      rep.last_ip_failure = hash['lastIPFailure']
      rep.last_failure    = hash['lastFailure']
      rep
    end
  end
end
