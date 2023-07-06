# frozen_string_literal: true

RSpec.describe KeycloakAdmin::AttackDetectionRepresentation do
  describe '.from_hash' do
    it 'converts json response to class structure' do
      rep = described_class.from_hash({
        'numFailures' => 2,
        'disabled' => true,
        'lastIPFailure' => 12345,
        'last_failure' => 12345678
      })
      expect(rep.num_failures).to eq 2
      expect(rep).to be_a described_class
    end
  end
end