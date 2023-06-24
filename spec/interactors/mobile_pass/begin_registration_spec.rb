RSpec.describe MobilePass::BeginRegistration do
  let(:call) { described_class.call username: }

  context "with all parameters" do
    let(:username) { "alice" }

    context "when there are no Agents with the username" do
      it "creates a new agent and returns webauthn credential options" do
        options = OpenStruct.new(challenge: "CHALLENGE")
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
        }
        .to change { MobilePass::Agent.count }.by(1)
      end
    end

    context "when there is already an agent with the username" do
      let(:username) { create(:agent).username }

      it "returns an appropriate error" do
        result = call
        expect(result).to be_failure
        expect(result.code).to eq :validation_errors
        expect(result.message).to eq "Username has already been taken"
      end
    end

    context "when the username is empty" do
      let(:username) { "" }

      it "returns an appropriate error" do
        result = call
        expect(result).to be_failure
        expect(result.code).to eq :validation_errors
        expect(result.message).to eq "Username can't be blank"
      end
    end
  end
end
