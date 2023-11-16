# frozen_string_literal: true

RSpec.describe KeycloakAdmin::AttackDetectionClient do
  describe "#initialize" do
    let(:realm_name) { nil }
    before(:each) do
      @realm = KeycloakAdmin.realm(realm_name)
    end
    context "when realm_name is defined" do
      let(:realm_name) { "master" }
      it "does not raise any error" do
        expect { @realm.attack_detections }.to_not raise_error
      end
    end

    context "when realm_name is not defined" do
      it "raise argument error" do
        expect { @realm.attack_detections }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#lock_status" do
    let(:realm_name) { "valid-realm" }
    before(:each) do
      @attack_detections = KeycloakAdmin.realm(realm_name).attack_detections
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:get).and_return '{"numFailures":1,"disabled":true, "lastFailure":123456}'
    end

    context "when user_id is defined" do
      let(:user_id) { "test_user_id" }
      it "returns lock details" do
        response = @attack_detections.lock_status(user_id)
        expect(response.num_failures).to eq 1
      end
    end

    context "when user_id is not defined" do
      let(:user_id) { nil }
      it "raise argument error" do
        expect { @attack_detections.lock_status(user_id) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#unlock_user" do
    let(:realm_name) { "valid-realm" }
    before(:each) do
      @attack_detections = KeycloakAdmin.realm(realm_name).attack_detections
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:delete)
    end

    context "when user_id is defined" do
      let(:user_id) { "test_user_id" }
      it "returns true" do
        expect(@attack_detections.unlock_user(user_id)).to be_truthy
      end
    end

    context "when user_id is not defined" do
      let(:user_id) { nil }
      it "raise argument error" do
        expect { @attack_detections.unlock_user(user_id) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#unlock_users" do
    let(:realm_name) { "valid-realm" }
    before(:each) do
      @attack_detections = KeycloakAdmin.realm(realm_name).attack_detections
      stub_token_client
      allow_any_instance_of(RestClient::Resource).to receive(:delete)
    end
    it "returns true" do
      expect(@attack_detections.unlock_users).to be_truthy
    end
  end

  describe "#brute_force_url" do
    let(:realm_name) { "valid-realm" }
    let(:user_id)    { nil }
    before(:each) do
      @attack_detections_url = KeycloakAdmin.realm(realm_name).attack_detections.brute_force_url(user_id)
    end

    context "when user_id is defined" do
      let(:user_id)    { "95985b21-d884-4bbd-b852-cb8cd365afc2" }
      it "returns user specific url" do
        expect(@attack_detections_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/attack-detection/brute-force/users/#{user_id}"
      end
    end

    context "when user_id is not defined" do
      it "returns url without user" do
        expect(@attack_detections_url).to eq "http://auth.service.io/auth/admin/realms/valid-realm/attack-detection/brute-force/users"
      end
    end
  end
end
