require "webauthn/attestation_statement/fido_u2f/public_key"
require "webauthn/authenticator_assertion_response"
require "webauthn/u2f_migrator"

RSpec.describe 'Register new user', type: :request do
  let(:challenge_params) { { username: } }
  let(:json_content_type_headers) { { 'Content-Type': 'application/json' } }
  let(:username) { "Test User" }

  let(:client) { WebAuthn::FakeClient.new(actual_origin, encoding: false) }
  let(:origin) { fake_origin }
  let(:actual_origin) { origin }
  let(:credential) { create_credential(client:) }
  let(:credential_public_key) { credential[1] }

  it "requests a challenge, follows up with a registration request, and receives a valid auth token" do
    post '/passkeys_rails/passkeys/challenge', params: challenge_params.to_json, headers: json_content_type_headers
    expect(response).to be_successful

    account = client.create(challenge: json[:challenge])

    pending "Figuring out how to create the params from the passkeys_rails/passkeys/challenge"
    # TODO: Not sure how create the params from the passkeys_rails/passkeys/challenge response that succeed"
    credential = {
      id: Base64.strict_encode64(account['id']),
      rawId: Base64.strict_encode64(account['rawId']),
      type: account['type'],
      response: {
        attestationObject: Base64.strict_encode64(account['response']['attestationObject']),
        clientDataJSON: Base64.strict_encode64(account['response']['clientDataJSON'])
      }
    }

    register_params = { credential: }

    post '/passkeys_rails/passkeys/register', params: register_params.to_json, headers: json_content_type_headers
    expect(json[:error]).to be_blank
    expect(response).to be_successful
  end
end
