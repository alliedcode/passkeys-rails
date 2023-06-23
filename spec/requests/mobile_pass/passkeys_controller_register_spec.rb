RSpec.describe MobilePass::PasskeysController do
  let(:call_api) { post '/mobile_pass/passkeys/register', params:, headers: }

  include_context 'params'

  it_behaves_like 'an api that requires some params'

  context 'with required params' do
    let(:required_params) { { credential: { id: '123', rawId: '123', type: 'hmm', response: auth_response } } }
    let(:auth_response) { { attestationObject: '123', clientDataJSON: '{}' } }

    # rubocop:disable RSpec/VerifiedDoubles
    context 'with valid parameters and a successfull call to FinishLogin' do
      let(:agent) { create(:agent) }

      it 'Succeeds and reutrns instance credentails' do
        allow(MobilePass::FinishRegistration)
          .to receive(:call!)
          .and_return(double(Interactor::Context, username: "name", auth_token: "123"))

        call_api
        expect_success
        expect(MobilePass::FinishRegistration).to have_received(:call!).exactly(1).time
        expect(json.keys).to match_array %w[username auth_token]
        expect(json).to include(username: "name", auth_token: "123")
      end
    end
    # rubocop:enable RSpec/VerifiedDoubles
  end
end
