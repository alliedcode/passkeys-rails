RSpec.describe PasskeysRails::BeginChallenge do
  let(:call) { described_class.call username: }

  context "with all parameters" do
    let(:username) { nil }

    context "without a username" do
      it "calls BeginAuthentication and returns the challenge, and options" do
        options = instance_double(WebAuthn::PublicKeyCredential::RequestOptions, challenge: "CHALLENGE")
        context = Interactor::Context.build(options:)

        allow(PasskeysRails::BeginAuthentication)
        .to receive(:call!)
        .and_return(context)
        .exactly(1).time

        result = call
        expect(result).to be_success
        expect(result.cookie_data[:username]).to be_nil
        expect(result.cookie_data[:challenge]).to eq "CHALLENGE"
        expect(result.response).to eq options
      end
    end

    context "with a username" do
      let(:username) { "alice" }

      it "calls BeginRegistration and returns the username, challenge, and options" do
        options = instance_double(WebAuthn::PublicKeyCredential::CreationOptions, challenge: "CHALLENGE")
        context = Interactor::Context.build(options:)

        allow(PasskeysRails::BeginRegistration)
        .to receive(:call!)
        .with(username:)
        .and_return(context)
        .exactly(1).time

        result = call
        expect(result).to be_success
        expect(result.cookie_data[:username]).to eq username
        expect(result.cookie_data[:challenge]).to eq "CHALLENGE"
        expect(result.response).to eq options
      end
    end
  end
end
