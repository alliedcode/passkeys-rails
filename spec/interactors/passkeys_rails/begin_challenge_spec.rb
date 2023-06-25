RSpec.describe PasskeysRails::BeginChallenge do
  let(:call) { described_class.call username: }

  context "with all parameters" do
    let(:username) { nil }

    context "without a username" do
      it "calls BeginAuthentication and returns the challenge, and options" do
        options = OpenStruct.new(challenge: "CHALLENGE")

        allow(PasskeysRails::BeginAuthentication)
          .to receive(:call!)
          .and_return(OpenStruct.new(options:))
          .exactly(1).time

        allow(WebAuthn).to receive_message_chain(:standard_encoder, :encode).with("CHALLENGE").and_return("ENCODED CHALLENGE")

        result = call
        expect(result).to be_success
        expect(result.session_data[:username]).to be_nil
        expect(result.session_data[:challenge]).to eq "ENCODED CHALLENGE"
        expect(result.response).to eq options
      end
    end

    context "with a username" do
      let(:username) { "alice" }

      it "calls BeginRegistration and returns the username, challenge, and options" do
        options = OpenStruct.new(challenge: "CHALLENGE")

        allow(PasskeysRails::BeginRegistration)
          .to receive(:call!)
          .with(username:)
          .and_return(OpenStruct.new(options:))
          .exactly(1).time

        allow(WebAuthn).to receive_message_chain(:standard_encoder, :encode).with("CHALLENGE").and_return("ENCODED CHALLENGE")

        result = call
        expect(result).to be_success
        expect(result.session_data[:username]).to eq username
        expect(result.session_data[:challenge]).to eq "ENCODED CHALLENGE"
        expect(result.response).to eq options
      end
    end
  end
end
