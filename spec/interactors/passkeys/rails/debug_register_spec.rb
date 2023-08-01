RSpec.describe PasskeysRails::DebugRegister do
  let(:call) { described_class.call username:, authenticatable_info: }

  context "with all parameters" do
    let(:username) { "adam-123" }
    let(:authenticatable_info) { { class: authenticatable_class, params: authenticatable_params } }
    let(:authenticatable_class) { nil }
    let(:authenticatable_params) { nil }
    let(:resulting_agent) { PasskeysRails::Agent.registered.find_by(username:) }

    shared_examples "a successful call" do |username|
      it "creates the agent and returns the username and auth token" do
        expect {
          result = call
          expect(result).to be_success
          expect(result.username).to eq username
          expect(result.auth_token).to be_present
          expect(result.agent).to be_a PasskeysRails::Agent

          expect(resulting_agent).to be_present
        }
        .to change { PasskeysRails::Agent.registered.count }.by(1)
      end
    end

    shared_examples "a related user creator" do
      it "creates a related user" do
        expect { expect(call).to be_success }
          .to change { User.count }.by(1)
      end

      it "relates a user to the resulting agent" do
        expect(call).to be_success
        expect(resulting_agent.authenticatable.class.name).to eq "User"
      end
    end

    shared_examples "only an agent creator" do
      it "doesn't change the user count" do
        expect { expect(call).to be_success }
          .to not_change { User.count }
      end

      it "doesn't relates a user to the resulting agent" do
        expect(call).to be_success
        expect(resulting_agent.authenticatable).to be_blank
      end
    end

    describe "debug_login_regex" do
      context "when there are no Agents with the username" do
        context "with an empty debug_login_regex" do
          before { allow(PasskeysRails).to receive(:debug_login_regex).and_return(nil) }

          it_behaves_like "a failing call", :not_allowed, "Action not allowed"
        end

        context "with a debug_login_regex that does not match the username" do
          before { allow(PasskeysRails).to receive(:debug_login_regex).and_return(/^eve-\d+$/) }

          it_behaves_like "a failing call", :not_allowed, "Invalid username"
        end

        context "with a debug_login_regex that matches the username" do
          before { allow(PasskeysRails).to receive(:debug_login_regex).and_return(/^adam-\d+$/) }

          it_behaves_like "a successful call", "adam-123"
        end
      end
    end

    context "with a debug_login_regex that matches the username" do
      before { allow(PasskeysRails).to receive(:debug_login_regex).and_return(/^adam-\d+$/) }

      context "when there is already an unregistered Agent with the username" do
        before { create(:agent, :unregistered, username:) }

        it_behaves_like "a successful call", "adam-123"
      end

      context "when there is already a registered Agent with the username" do
        before { create(:agent, :registered, username:) }

        it_behaves_like "a failing call", :validation_errors, "Username has already been taken"
      end

      describe 'authenticatable_class' do
        context "when there are no Agents with the username" do
          context "when the authenticatable_class is not supplied" do
            let(:authenticatable_info) { nil }

            context "when the default_class is nil" do
              before { PasskeysRails.default_class = nil }

              it_behaves_like "a successful call", "adam-123"
              it_behaves_like "only an agent creator"
            end

            context "when the default_class is User" do
              before { PasskeysRails.default_class = "User" }

              context "when the class_whitelist is nil" do
                before { PasskeysRails.class_whitelist = nil }

                it_behaves_like "a successful call", "adam-123"
                it_behaves_like "a related user creator"
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

                it_behaves_like "a successful call", "adam-123"
                it_behaves_like "a related user creator"
              end

              context "when the class_whitelist is a string (invalid)" do
                before { PasskeysRails.class_whitelist = "invalid" }

                it_behaves_like "a failing call", :invalid_class_whitelist, "class_whitelist is invalid.  It should be nil or an array of zero or more class names."
              end
            end
          end

          context "when the authenticatable_class is a valid class" do
            let(:authenticatable_class) { "User" }

            it_behaves_like "a successful call", "adam-123"
            it_behaves_like "a related user creator"
          end

          context "when the authenticatable_class matches a class that doesn't pass validation when created" do
            let(:authenticatable_class) { "Contact" }

            it_behaves_like "a failing call", :record_invalid, /Validation failed:/
          end

          context "when the authenticatable_class doesn't match any known classes" do
            let(:authenticatable_class) { "Unknown" }

            it_behaves_like "a failing call", :invalid_authenticatable_class, "authenticatable_class (Unknown) is not defined"
          end
        end
      end
    end
  end
end
