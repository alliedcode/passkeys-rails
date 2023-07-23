RSpec.describe Passkeys::Rails::BeginChallenge do
  let(:call) { described_class.call username: }

  def stub_webauthn(challenge:, encoded_response:)
    standard_encoder = instance_double(WebAuthn::Encoder)
    allow(WebAuthn).to receive(:standard_encoder).and_return(standard_encoder)
    allow(standard_encoder).to receive(:encode).with(challenge).and_return(encoded_response)
  end

  context "with all parameters" do
    let(:username) { nil }

    context "without a username" do
      it "calls BeginAuthentication and returns the challenge, and options" do
        options = instance_double(WebAuthn::PublicKeyCredential::RequestOptions, challenge: "CHALLENGE")
        context = Interactor::Context.build(options:)

        allow(Passkeys::Rails::BeginAuthentication)
          .to receive(:call!)
          .and_return(context)
          .exactly(1).time

        stub_webauthn(challenge: "CHALLENGE", encoded_response: "ENCODED CHALLENGE")

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
        options = instance_double(WebAuthn::PublicKeyCredential::CreationOptions, challenge: "CHALLENGE")
        context = Interactor::Context.build(options:)

        allow(Passkeys::Rails::BeginRegistration)
          .to receive(:call!)
          .with(username:)
          .and_return(context)
          .exactly(1).time

        stub_webauthn(challenge: "CHALLENGE", encoded_response: "ENCODED CHALLENGE")

        result = call
        expect(result).to be_success
        expect(result.session_data[:username]).to eq username
        expect(result.session_data[:challenge]).to eq "ENCODED CHALLENGE"
        expect(result.response).to eq options
      end
    end
  end
end
