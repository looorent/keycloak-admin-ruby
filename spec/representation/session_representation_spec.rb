# frozen_string_literal: true

RSpec.describe KeycloakAdmin::SessionRepresentation do
  describe '.from_hash' do
    it 'converts json response to class structure' do
      rep = described_class.from_hash({
        'username' => 'test_username',
        'userId' => '95985b21-d884-4bbd-b852-cb8cd365afc2',
        'ipAddress' => '1.1.1.1',
        'start' => 12345678
      })
      expect(rep.user_id).to eq '95985b21-d884-4bbd-b852-cb8cd365afc2'
      expect(rep).to be_a described_class
    end
  end
end