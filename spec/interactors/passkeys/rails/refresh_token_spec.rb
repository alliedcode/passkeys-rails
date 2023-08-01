RSpec.describe PasskeysRails::RefreshToken do
  let(:call) { described_class.call token: }
  let(:agent) { create(:agent) }
  let(:token) { nil }

  context "with a valid, non-expired token" do
    let(:token) { PasskeysRails::GenerateAuthToken.call(agent:).auth_token }

    it "returns a new auth token that expires in the future" do
      result = call
      expect(result).to be_success

      token = result.auth_token
      expect(token).to be_a String
      expect(result.agent).to be_a PasskeysRails::Agent

      payload, = JWT.decode(token, PasskeysRails.auth_token_secret, true, { algorithm: PasskeysRails.auth_token_algorithm })

      expect(payload['agent_id']).to eq agent.id
      expect(payload['exp']).to be_present
      expect(Time.zone.at(payload['exp'])).to be_future
    end
  end

  context "with an bogus token" do
    let(:token) { "BOGUS" }

    it_behaves_like "a failing call", :token_error, "Not enough or too many segments"
  end

  context "with a valid, but expired token" do
    let(:token) { Timecop.freeze(1.year.ago) { PasskeysRails::GenerateAuthToken.call(agent:).auth_token } }

    it_behaves_like "a failing call", :expired_token, "The token has expired"
  end
end
