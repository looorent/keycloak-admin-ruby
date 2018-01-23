RSpec.describe KeycloakAdmin::ImpersonationRepresentation do
  describe "#parse_set_cookie_string" do

    let(:origin)            { "http://auth.service.io" }
    let(:set_cookie_string) { "" }

    before(:each) do
      @cookie = KeycloakAdmin::ImpersonationRepresentation.parse_set_cookie_string(set_cookie_string, origin)
    end

    shared_context "common properties are read properly" do
      it "parses its domain property" do
        expect(@cookie.domain).to eq "auth.service.io"
      end

      it "parses its for_domain property" do
        expect(@cookie.for_domain).to be false
      end

      it "parses its Path property" do
        expect(@cookie.path).to eq "/auth/realms/a-realm"
      end

      it "parses its Secure property" do
        expect(@cookie.secure).to be false
      end
    end

    context "when result is an expiring empty KEYCLOAK_IDENTITY" do
      let(:set_cookie_string) { "KEYCLOAK_IDENTITY=; Version=1; Comment=Expiring cookie; Expires=Thu, 01-Jan-1970 00:00:10 GMT; Max-Age=0; Path=/auth/realms/a-realm; HttpOnly" }
      
      include_examples "common properties are read properly"

      it "parses its name property" do
        expect(@cookie.name).to eq "KEYCLOAK_IDENTITY"
      end

      it "parses its value property" do
        expect(@cookie.value).to eq ""
      end

      it "parses its Expires property" do
        expect(@cookie.expires).to be <= Time.now
      end

      it "parses its Max-Age property" do
        expect(@cookie.max_age).to eq 0
      end

      it "parses its HttpOnly property" do
        expect(@cookie.httponly).to be true
      end
    end


    context "when result is an expiring empty KEYCLOAK_SESSION" do
      let(:set_cookie_string) { "KEYCLOAK_SESSION=; Version=1; Comment=Expiring cookie; Expires=Thu, 01-Jan-1970 00:00:10 GMT; Max-Age=0; Path=/auth/realms/a-realm" }
      
      include_examples "common properties are read properly"

      it "parses its name property" do
        expect(@cookie.name).to eq "KEYCLOAK_SESSION"
      end

      it "parses its value property" do
        expect(@cookie.value).to eq ""
      end

      it "parses its Expires property" do
        expect(@cookie.expires).to be <= Time.now
      end

      it "parses its Max-Age property" do
        expect(@cookie.max_age).to eq 0
      end

      it "parses its HttpOnly property" do
        expect(@cookie.httponly).to be false
      end
    end


    context "when result is an expiring empty KEYCLOAK_REMEMBER_ME" do
      let(:set_cookie_string) { "KEYCLOAK_REMEMBER_ME=; Version=1; Comment=Expiring cookie; Expires=Thu, 01-Jan-1970 00:00:10 GMT; Max-Age=0; Path=/auth/realms/a-realm; HttpOnly" }
      
      include_examples "common properties are read properly"

      it "parses its name property" do
        expect(@cookie.name).to eq "KEYCLOAK_REMEMBER_ME"
      end

      it "parses its value property" do
        expect(@cookie.value).to eq ""
      end

      it "parses its Expires property" do
        expect(@cookie.expires).to be <= Time.now
      end

      it "parses its Max-Age property" do
        expect(@cookie.max_age).to eq 0
      end

      it "parses its HttpOnly property" do
        expect(@cookie.httponly).to be true
      end
    end

    context "when result is a new KEYCLOAK_IDENTITY" do
      let(:set_cookie_string) { "KEYCLOAK_IDENTITY=eyJhbGciOiJIUzI1NiIsImtpZCIgOiAiMDQyMTcwMWItY2I2Ny00YzQ4LWIzZWYtMDBlMDhhMmE4MjNjIn0.eyJqdGkiOiI5ZTEyODc3MC1mN2U1LTQ0OWYtYWMzYi03OTAzN2Q5NDBhOTMiLCJleHAiOjE1MTY2ODE2ODIsIm5iZiI6MCwiaWF0IjoxNTE2NjQ1NjgyLCJpc3MiOiJodHRwOi8vYXV0aDo4MDgwL2F1dGgvcmVhbG1zL2NvbW11dHkiLCJzdWIiOiI0NGM1MzdmMi1iMzBiLTRlZTctYjI4Ni1lZTY2NjI2NDcwYWMiLCJhdXRoX3RpbWUiOjAsInNlc3Npb25fc3RhdGUiOiI3ZDI5NTJlZS0xMjllLTRmOGQtYmFjNy1jMWE0YWUxNGRjY2QiLCJyZXNvdXJjZV9hY2Nlc3MiOnt9LCJzdGF0ZV9jaGVja2VyIjoiUEdXZVdXc3hMRmN3WG1QelFmMGxBQTJrN1V3Skg3UUlHU0lrN3hmWUFEbyJ9.Hw9EM1rZLXkUfE97tfS8jw8MFogfMoGpT34yoMupK3E; Version=1; Path=/auth/realms/a-realm; HttpOnly" }
      
      include_examples "common properties are read properly"

      it "parses its name property" do
        expect(@cookie.name).to eq "KEYCLOAK_IDENTITY"
      end

      it "parses its value property" do
        expect(@cookie.value).to eq "eyJhbGciOiJIUzI1NiIsImtpZCIgOiAiMDQyMTcwMWItY2I2Ny00YzQ4LWIzZWYtMDBlMDhhMmE4MjNjIn0.eyJqdGkiOiI5ZTEyODc3MC1mN2U1LTQ0OWYtYWMzYi03OTAzN2Q5NDBhOTMiLCJleHAiOjE1MTY2ODE2ODIsIm5iZiI6MCwiaWF0IjoxNTE2NjQ1NjgyLCJpc3MiOiJodHRwOi8vYXV0aDo4MDgwL2F1dGgvcmVhbG1zL2NvbW11dHkiLCJzdWIiOiI0NGM1MzdmMi1iMzBiLTRlZTctYjI4Ni1lZTY2NjI2NDcwYWMiLCJhdXRoX3RpbWUiOjAsInNlc3Npb25fc3RhdGUiOiI3ZDI5NTJlZS0xMjllLTRmOGQtYmFjNy1jMWE0YWUxNGRjY2QiLCJyZXNvdXJjZV9hY2Nlc3MiOnt9LCJzdGF0ZV9jaGVja2VyIjoiUEdXZVdXc3hMRmN3WG1QelFmMGxBQTJrN1V3Skg3UUlHU0lrN3hmWUFEbyJ9.Hw9EM1rZLXkUfE97tfS8jw8MFogfMoGpT34yoMupK3E"
      end

      it "parses its Expires property" do
        expect(@cookie.expires).to be_nil
      end

      it "parses its Max-Age property" do
        expect(@cookie.max_age).to be nil
      end

      it "parses its HttpOnly property" do
        expect(@cookie.httponly).to be true
      end
    end

    context "when result is a new KEYCLOAK_SESSION" do
      let(:set_cookie_string) { "KEYCLOAK_SESSION=commuty/44c537f2-b30b-4ee7-b286-ee66626470ac/cd79f3c2-7cee-4c4e-980b-43293aaaff88; Version=1; Expires=Tue, 23-Jan-2018 23:56:32 GMT; Max-Age=36000; Path=/auth/realms/a-realm" }
      
      include_examples "common properties are read properly"

      it "parses its name property" do
        expect(@cookie.name).to eq "KEYCLOAK_SESSION"
      end

      it "parses its value property" do
        expect(@cookie.value).to eq "commuty/44c537f2-b30b-4ee7-b286-ee66626470ac/cd79f3c2-7cee-4c4e-980b-43293aaaff88"
      end

      it "parses its Expires property" do
        expect(@cookie.expires).to_not be_nil
      end

      it "parses its Max-Age property" do
        expect(@cookie.max_age).to be 36000
      end

      it "parses its HttpOnly property" do
        expect(@cookie.httponly).to be false
      end
    end
  end
end


