text = File.read('spec/client/organization_client_spec.rb')

text.gsub!(/allow_any_instance_of\(KeycloakAdmin::Resource\)\.to receive\(:(\w+)\)\.and_return (.+)/) do |m|
  method = $1
  ret = $2
  %{stub_request(:#{method}, /.*/).to_return(body: #{ret})}
end

text.gsub!(/expect\(KeycloakAdmin::Resource\)\.to receive\(:new\)\.with\(\n\s*"([^"]+)", faraday_options, anything\)\.and_call_original/) do |m|
  url = $1
  %{stub_request(:any, /.*/).to_return(body: json_payload)}
end

text.gsub!(/expect\(KeycloakAdmin::Resource\)\.to receive\(:new\)\.with\(\n\s*"([^"]+)", faraday_options, anything\)\.and_raise\("error"\)/) do |m|
  url = $1
  %{stub_request(:delete, /.*/).to_raise("error")}
end

File.write('spec/client/organization_client_spec.rb', text)
