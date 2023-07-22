require "webauthn"
require "webauthn/fake_client"

module Requests
  module WebauthnHelpers
    def fake_origin
      "http://localhost"
    end

    def fake_challenge
      SecureRandom.random_bytes(32)
    end

    def fake_cose_credential_key(algorithm: -7, x_coordinate: nil, y_coordinate: nil)
      crv_p256 = 1

      COSE::Key::EC2.new(
        alg: algorithm,
        crv: crv_p256,
        x: x_coordinate || SecureRandom.random_bytes(32),
        y: y_coordinate || SecureRandom.random_bytes(32)
      ).serialize
    end

    def create_credential(
      client: WebAuthn::FakeClient.new,
      rp_id: nil,
      relying_party: WebAuthn.configuration.relying_party
    )
      rp_id ||= relying_party.id || URI.parse(client.origin).host

      create_result = client.create(rp_id:)

      attestation_object =
        if client.encoding
          relying_party.encoder.decode(create_result["response"]["attestationObject"])
        else
          create_result["response"]["attestationObject"]
        end

      client_data_json =
        if client.encoding
          relying_party.encoder.decode(create_result["response"]["clientDataJSON"])
        else
          create_result["response"]["clientDataJSON"]
        end

      response =
        WebAuthn::AuthenticatorAttestationResponse
        .new(
          attestation_object:,
          client_data_json:,
          relying_party:
        )

      credential_public_key = response.credential.public_key

      [create_result["id"], credential_public_key, response.authenticator_data.sign_count]
    end
  end
end
