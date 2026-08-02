# frozen_string_literal: true
RSpec.describe KeycloakAdmin::ApiError do
  describe ".from_response" do
    def error_for(status)
      described_class.from_response(status: status, body: "body", headers: {"x" => "y"})
    end

    {
      400 => KeycloakAdmin::BadRequestError,
      401 => KeycloakAdmin::UnauthorizedError,
      403 => KeycloakAdmin::ForbiddenError,
      404 => KeycloakAdmin::NotFoundError,
      409 => KeycloakAdmin::ConflictError
    }.each do |status, expected_class|
      it "maps #{status} to #{expected_class}" do
        expect(error_for(status)).to be_a expected_class
      end
    end

    it "maps any other 4xx to the generic ClientError" do
      expect(error_for(429)).to be_an_instance_of KeycloakAdmin::ClientError
    end

    it "maps 5xx to ServerError" do
      expect(error_for(503)).to be_an_instance_of KeycloakAdmin::ServerError
    end

    it "falls back to ApiError when the failure carried no status" do
      expect(described_class.from_response(nil)).to be_an_instance_of KeycloakAdmin::ApiError
    end

    it "exposes the status, body and headers so callers need not parse the message" do
      error = error_for(404)
      expect(error.status).to eq 404
      expect(error.body).to eq "body"
      expect(error.headers).to eq({"x" => "y"})
    end

    it "keeps the message identical to the RuntimeError previously raised" do
      expect(error_for(404).message).to eq "Keycloak: The request failed with response code 404 and message: body"
    end
  end

  describe "hierarchy" do
    it "lets a caller rescue one precise failure" do
      expect(KeycloakAdmin::NotFoundError.new(404, "x")).to be_a KeycloakAdmin::NotFoundError
    end

    it "groups every 4xx under ClientError" do
      expect(KeycloakAdmin::ApiError.error_class_for(404).ancestors).to include KeycloakAdmin::ClientError
    end

    it "groups every HTTP failure under ApiError, and every gem error under Error" do
      [KeycloakAdmin::ClientError, KeycloakAdmin::ServerError].each do |klass|
        expect(klass.ancestors).to include KeycloakAdmin::ApiError
      end
      expect(KeycloakAdmin::ApiError.ancestors).to include KeycloakAdmin::Error
      expect(KeycloakAdmin::Error.ancestors).to include StandardError
    end
  end
end

RSpec.describe KeycloakAdmin::UnexpectedResponseError do
  it "keeps the message identical to the RuntimeError previously raised" do
    error = described_class.new(200, "OK")
    expect(error.message).to eq "Create method returned status OK (Code: 200); expected status: Created (201)"
    expect(error.status).to eq 200
  end
end
