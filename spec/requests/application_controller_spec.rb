RSpec.describe ApplicationController do
  let(:get_index) { get '/', params:, headers: }
  let(:get_home) { get '/home', params:, headers: }

  include_context 'params'

  context "without an auth token" do
    context 'when visiting the index page' do
      it "is unauthorized" do
        get_index
        expect(response.code.to_i).to eq 401
        expect(error).to match([:authentication, 'unauthorized', "You are not authorized to access this resource."])
      end
    end

    context 'when visiting the home page' do
      it "renders, but there's no username" do
        get_home
        expect(response.code.to_i).to eq 200
        expect(json[:username]).to be_nil
      end
    end
  end

  context "with a valid auth token" do
    let(:agent) { create(:agent) }
    let(:additional_headers) { { 'X-Auth' => MobilePass::GenerateAuthToken.call(agent:).auth_token } }

    context 'when visiting the index page' do
      it "renders the username" do
        get_index
        expect(response.code.to_i).to eq 200
        expect(json[:username]).to eq agent.username
      end
    end

    context 'when visiting the home page' do
      it "renders the username" do
        get_index
        expect(response.code.to_i).to eq 200
        expect(json[:username]).to eq agent.username
      end
    end
  end
end
