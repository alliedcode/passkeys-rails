RSpec.describe PasskeysRails::BeginRegistration do
  let(:call) { described_class.call username: }

  RSpec.shared_examples 'an agent creator' do
    it 'creates a new agent and returns webauthn credential options' do
      options = instance_double(WebAuthn::PublicKeyCredential::CreationOptions, challenge: "CHALLENGE")
      user_identifier = "SOME ID"

      allow(WebAuthn).to receive(:generate_user_id).and_return(user_identifier)

      allow(WebAuthn::Credential)
        .to receive(:options_for_create)
        .with(user: { id: user_identifier, name: username })
        .and_return(options)
        .exactly(1).time

      expect {
        result = call
        expect(result).to be_success
        expect(result.options).to eq options
        expect(PasskeysRails::Agent.unregistered.find_by(username:)).to be_present
      }
      .not_to change { PasskeysRails::Agent.registered.count }
    end
  end

  context "with all parameters" do
    let(:username) { "alice" }

    context "when there are no Agents with the username" do
      it_behaves_like "an agent creator"
    end

    context "when there is already an unregistered Agent with the username" do
      let(:username) { create(:agent, :unregistered).username }

      it_behaves_like "an agent creator"
    end

    context "when there is already a registered Agent with the username" do
      let(:username) { create(:agent, :registered).username }

      it_behaves_like "a failing call", :validation_errors, "Username has already been taken"
    end

    context "when the username is empty" do
      let(:username) { "" }

      it_behaves_like "a failing call", :validation_errors, "Username can't be blank"
    end
  end
end
