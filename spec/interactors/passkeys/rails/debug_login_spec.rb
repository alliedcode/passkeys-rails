RSpec.describe PasskeysRails::DebugLogin do
  let(:call) { described_class.call username: }

  context "with all parameters" do
    let(:username) { nil }

    context "with an agent" do
      let(:agent) { create(:agent, username: 'adam-123') }

      context "when the username matches the agent" do
        let(:username) { agent.username }

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

          it "returns the username and auth token" do
            result = call
            expect(result).to be_success
            expect(result.username).to eq agent.username
            expect(result.auth_token).to be_present
          end
        end

        context "when the username doesn't match the agent" do
          let(:username) { "kane-123" }

          context "with a debug_login_regex that matches the username" do
            before { allow(PasskeysRails).to receive(:debug_login_regex).and_return(/^kane-\d+$/) }

            it_behaves_like "a failing call", :agent_not_found, "No agent found with that username"
          end
        end
      end
    end
  end
end
