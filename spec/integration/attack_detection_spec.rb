require 'spec_helper'

RSpec.describe 'Attack Detection Integration' do
  let(:realm_name) { "dummy" }

  it 'fetches lock status for a user and unlocks them' do
    users_client = KeycloakAdmin.realm(realm_name).users
    ad_client = KeycloakAdmin.realm(realm_name).attack_detections

    username = "attack-user-#{SecureRandom.hex(4)}"
    created_user = users_client.create!(username, "#{username}@example.com", "password", true, "en")
    
    # 1. Get lock status
    status = ad_client.lock_status(created_user.id)
    expect(status).not_to be_nil
    expect(status.disabled).to be_falsey
    expect(status.num_failures).to eq(0)

    # 2. Unlock user
    expect(ad_client.unlock_user(created_user.id)).to be_truthy

    # 3. Unlock all users
    expect(ad_client.unlock_users).to be_truthy

    # Cleanup
    users_client.delete(created_user.id)
  end


end
