RSpec.describe MobilePass::RefreshToken do
  let(:call) { described_class.call token: }
  let(:agent) { create(:agent) }
  let(:token) { nil }

  context "with a valid, non-expired token" do
    let(:token) { MobilePass::GenerateAuthToken.call(agent:).auth_token }

    it "returns a new auth token that expires in the future" do
      result = call
      expect(result).to be_success

      token = result.auth_token
      expect(token).to be_a String

      payload, = JWT.decode(token, MobilePass.auth_token_secret, true, { algorithm: MobilePass.auth_token_algorithm })

      expect(payload['agent_id']).to eq agent.id
      expect(payload['exp']).to be_present
      expect(Time.zone.at(payload['exp'])).to be_future
    end
  end

  context "with an bogus token" do
    let(:token) { "BOGUS" }

    it "returns an appropriate error" do
      result = call
      expect(result).to be_failure
      expect(result.code).to eq :token_error
      expect(result.message).to eq "Not enough or too many segments"
    end
  end

  context "with a valid, but expired token" do
    let(:token) { Timecop.freeze(1.year.ago) { MobilePass::GenerateAuthToken.call(agent:).auth_token } }

    it "returns an appropriate error" do
      result = call
      expect(result).to be_failure
      expect(result.code).to eq :expired_token
      expect(result.message).to eq "The token has expired"
    end
  end
end
