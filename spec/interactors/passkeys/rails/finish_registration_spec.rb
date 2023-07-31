RSpec.describe PasskeysRails::FinishRegistration do
  let(:call) { described_class.call credential:, username:, challenge: original_challenge, authenticatable_info: }

  shared_examples "a successful call" do |username|
    it "updates the agent and returns the username and auth token" do
      expect {
        result = call
        expect(result).to be_success
        expect(result.username).to eq username
        expect(result.auth_token).to be_present
      }
      .to change { agent.reload.registered_at }.from(nil)
      .and change { agent.reload.registered? }.to(true)
    end
  end

  shared_examples "a user creator" do
    it "passes authenticatable_params to the related user's registering_with method" do
      user = User.new
      allow(User).to receive(:new).and_return(user)
      allow(user).to receive(:agent=).with(agent)
      allow(user).to receive(:registering_with).with(authenticatable_params)

      expect(call).to be_success

      expect(User).to have_received(:new).once
      expect(user).to have_received(:agent=).once
      expect(user).to have_received(:registering_with).once
    end

    it "creates a related user" do
      expect { expect(call).to be_success }
        .to change { User.count }.by(1)
        .and change { agent.reload.authenticatable }.from(nil)
    end
  end

  context "with all parameters" do
    let(:authenticatable_info) { { class: authenticatable_class, params: authenticatable_params } }
    let(:authenticatable_class) { nil }
    let(:authenticatable_params) { nil }
    let(:credential) { nil }
    let(:username) { nil }
    let(:original_challenge) { "CHALLENGE" }
    let(:credential_identifier) { "SOME ID" }

    context "when the credential doesn't verify" do
      before {
        attestation_credential = instance_double(WebAuthn::PublicKeyCredentialWithAttestation, id: credential_identifier, public_key: 'pk', sign_count: 0)
        allow(WebAuthn::Credential).to receive(:from_create).with(credential).and_return(attestation_credential)
        allow(attestation_credential).to receive(:verify).with(original_challenge).and_raise(WebAuthn::Error.new)
      }

      it_behaves_like "a failing call", :webauthn_error, "WebAuthn::Error"
    end

    context "when the credential and challenge are valid" do
      let(:credential) { { id: '123', rawId: '123', type: 'hmm', response: auth_response } }
      let(:auth_response) { { attestationObject: '123', clientDataJSON: '{}' } }

      before do
        attestation_credential = instance_double(WebAuthn::PublicKeyCredentialWithAttestation, id: credential_identifier, public_key: 'pk', sign_count: 0)
        allow(WebAuthn::Credential).to receive(:from_create).with(credential).and_return(attestation_credential)
        allow(attestation_credential).to receive(:verify).with(original_challenge)
      end

      context "when the username matches an existing agent" do
        let!(:agent) { create(:agent, username: "Some User") }
        let(:username) { agent.username }

        context "when there is already a passkey with the given identifier" do
          before { create(:passkey, identifier: credential_identifier) }

          it_behaves_like "a failing call", :passkey_error, /Validation failed:/
        end

        context "when the authenticatable_class is not supplied" do
          context "when the default_class is nil" do
            before { PasskeysRails.default_class = nil }

            it_behaves_like "a successful call", "Some User"

            it "doesn't change the user count" do
              expect { expect(call).to be_success }
                .to not_change { User.count }
                .and not_change { agent.reload.authenticatable }.from(nil)
            end
          end

          context "when the default_class is User" do
            before { PasskeysRails.default_class = "User" }

            context "when the class_whitelist is nil" do
              before { PasskeysRails.class_whitelist = nil }

              it_behaves_like "a successful call", "Some User"
              it_behaves_like "a user creator"

              context "when authenticatable_params are supplied" do
                let(:authenticatable_params) { { some: 'more data' } }

                it_behaves_like "a successful call", "Some User"
                it_behaves_like "a user creator"
              end
            end

            context "when the class_whitelist is an empty array" do
              before { PasskeysRails.class_whitelist = [] }

              it_behaves_like "a failing call", :invalid_authenticatable_class, "authenticatable_class (User) is not in the whitelist"
            end

            context "when the class_whitelist is an array, but User is not in it" do
              before { PasskeysRails.class_whitelist = %w[Account AdminUser] }

              it_behaves_like "a failing call", :invalid_authenticatable_class, "authenticatable_class (User) is not in the whitelist"
            end

            context "when the class_whitelist includes User" do
              before { PasskeysRails.class_whitelist = %w[Account User AdminUser] }

              it_behaves_like "a successful call", "Some User"
              it_behaves_like "a user creator"
            end

            context "when the class_whitelist is a string (invalid)" do
              before { PasskeysRails.class_whitelist = "invalid" }

              it_behaves_like "a failing call", :invalid_class_whitelist, "class_whitelist is invalid.  It should be nil or an array of zero or more class names."
            end
          end
        end

        context "when the authenticatable_class is a valid class" do
          let(:authenticatable_class) { "User" }

          context "when PasskeysRails.default_class is nil" do
            before { PasskeysRails.default_class = nil }

            it_behaves_like "a successful call", "Some User"
            it_behaves_like "a user creator"
          end

          context "when PasskeysRails.default_class is a different valid class" do
            before { PasskeysRails.default_class = "Contact" }

            it_behaves_like "a successful call", "Some User"
            it_behaves_like "a user creator"
          end

          it_behaves_like "a successful call", "Some User"
          it_behaves_like "a user creator"
        end

        context "when the authenticatable_class matches a class that doesn't pass validation when created" do
          let(:authenticatable_class) { "Contact" }

          it_behaves_like "a failing call", :record_invalid, /Validation failed:/

          it "doesn't change the agent" do
            expect { expect(call).to be_failure }.to not_change { agent.reload }
          end
        end

        context "when the authenticatable_class doesn't match any known classes" do
          let(:authenticatable_class) { "Unknown" }

          it_behaves_like "a failing call", :invalid_authenticatable_class, "authenticatable_class (Unknown) is not defined"

          it "doesn't change the agent" do
            expect { expect(call).to be_failure }.to not_change { agent.reload }
          end
        end
      end

      context "when the username doesn't match any agents" do
        let(:username) { "somebody else" }

        it_behaves_like "a failing call", :agent_not_found, "Agent not found for session value: \"somebody else\""
      end
    end
  end
end
