RSpec.describe PasskeysRails::FinishAuthentication do
  let(:call) { described_class.call credential:, challenge: original_challenge }

  context "with all parameters" do
    let(:credential) { nil }
    let(:challenge) { nil }

    context "with a passkey" do
      let!(:passkey) { create(:passkey) }

      context "when the credential and challenge are valid and match the passkey" do
        let(:credential) { { id: '123', rawId: '123', type: 'hmm', response: auth_response } }
        let(:auth_response) { { attestationObject: '123', clientDataJSON: '{}' } }
        let(:original_challenge) { "CHALLENGE" }

        before do
          assertion_credential = instance_double(WebAuthn::PublicKeyCredentialWithAssertion, id: passkey.identifier, sign_count: passkey.sign_count)
          allow(WebAuthn::Credential).to receive(:from_get).with(credential).and_return(assertion_credential)
          allow(assertion_credential).to receive(:verify).with(original_challenge, public_key: passkey.public_key, sign_count: passkey.sign_count)
        end

        it "returns the username and auth token" do
          expect {
            result = call
            expect(result).to be_success
            expect(result.username).to eq passkey.agent.username
            expect(result.auth_token).to be_present
          }
          .to change { passkey.reload.agent.last_authenticated_at }
        end

        context "when the passkey has invalid data" do
          let(:credential) { { id: '123', rawId: '123', type: 'hmm', response: auth_response } }
          let(:auth_response) { { attestationObject: '123', clientDataJSON: '{}' } }
          let(:original_challenge) { "CHALLENGE" }

          before do
            assertion_credential = instance_double(WebAuthn::PublicKeyCredentialWithAssertion, id: passkey.identifier, sign_count: passkey.sign_count)
            allow(WebAuthn::Credential).to receive(:from_get).with(credential).and_return(assertion_credential)
            allow(assertion_credential).to receive(:verify)
                                       .with(original_challenge, public_key: passkey.public_key, sign_count: passkey.sign_count)
                                       .and_raise(WebAuthn::Error.new)
          end

          it_behaves_like "a failing call", :webauthn_error, "WebAuthn::Error"
        end
      end
    end

    context "without a passkey" do
      context "when the credential and challenge are not valid" do
        let(:credential) { { id: '123', rawId: '123', type: 'hmm', response: auth_response } }
        let(:auth_response) { { attestationObject: '123', clientDataJSON: '{}' } }
        let(:original_challenge) { "CHALLENGE" }

        before do
          assertion_credential = instance_double(WebAuthn::PublicKeyCredentialWithAssertion, id: 'hmm', sign_count: 0)
          allow(WebAuthn::Credential).to receive(:from_get).with(credential).and_return(assertion_credential)
        end

        it_behaves_like "a failing call", :passkey_not_found, "Unable to find the specified passkey"
      end
    end
  end
end
