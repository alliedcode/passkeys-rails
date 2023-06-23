RSpec.describe MobilePass::FinishRegistration do
  let(:call) { described_class.call credential:, username:, challenge: original_challenge, authenticatable_class: }

  context "with all parameters" do
    let(:authenticatable_class) { nil }
    let(:credential) { nil }
    let(:username) { nil }
    let(:challenge) { nil }

    context "when the credential and challenge are valid" do
      let(:credential) { { id: '123', rawId: '123', type: 'hmm', response: auth_response } }
      let(:auth_response) { { attestationObject: '123', clientDataJSON: '{}' } }
      let(:original_challenge) { "CHALLENGE" }

      before do
        attestation_credential = instance_double(WebAuthn::PublicKeyCredentialWithAttestation, id: 'id', public_key: 'pk', sign_count: 0)
        allow(WebAuthn::Credential).to receive(:from_create).with(credential).and_return(attestation_credential)
        allow(attestation_credential).to receive(:verify).with(original_challenge)
      end

      context "when the username matches an existing agent" do
        let!(:agent) { create(:agent) }
        let(:username) { agent.username }

        context "when the authenticatable_class is not supplied" do
          it "updates the agent and returns the username and auth token" do
            expect {
              result = call
              expect(result).to be_success
              expect(result.username).to eq username
              expect(result.auth_token).to be_present
            }
            .to change { agent.reload.registered_at }.from(nil)
            .and change { agent.reload.registered? }.to(true)
            .and not_change { User.count }
            .and not_change { agent.reload.authenticatable }.from(nil)
          end
        end

        context "when the authenticatable_class is a valid class" do
          let(:authenticatable_class) { "User" }

          it "updates the agent, creates a related user, and returns the username and auth token" do
            expect {
              result = call
              expect(result).to be_success
              expect(result.username).to eq username
              expect(result.auth_token).to be_present
            }
            .to change { agent.reload.registered_at }.from(nil)
            .and change { agent.reload.registered? }.to(true)
            .and change { User.count }.by(1)
            .and change { agent.reload.authenticatable }.from(nil)
          end
        end

        context "when the authenticatable_class matches a class that doesn't meet the requirements" do
          let(:authenticatable_class) { "MobilePass::Passkey" }

          it "fails with an appropriate message" do
            expect {
              result = call
              expect(result).to be_failure
              expect(result.code).to eq :invalid_authenticatable_class
              expect(result.message).to eq "authenticatable_class (#{authenticatable_class}) must respond to did_register(Agent)"
            }
            .to not_change { agent.reload }
          end
        end

        context "when the authenticatable_class doesn't match any known classes" do
          let(:authenticatable_class) { "Unknown" }

          it "fails with an appropriate message" do
            expect {
              result = call
              expect(result).to be_failure
              expect(result.code).to eq :invalid_authenticatable_class
              expect(result.message).to eq "authenticatable_class (#{authenticatable_class}) is not defined"
            }
            .to not_change { agent.reload }
          end
        end
      end

      context "when the username doesn't match any agents" do
        let(:username) { "somebody else" }

        it "fails with an appropriate message" do
          result = call
          expect(result).to be_failure
          expect(result.code).to eq :agent_not_found
          expect(result.message).to eq "Agent not found for session value: \"#{username}\""
        end
      end
    end
  end
end
