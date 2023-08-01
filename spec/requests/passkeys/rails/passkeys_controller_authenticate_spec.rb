RSpec.describe PasskeysRails::PasskeysController do
  let(:call_api) { post '/passkeys_rails/authenticate', params:, headers: }

  include_context 'with api params'

  it_behaves_like 'an api that requires some params'

  context 'with required params' do
    let(:required_params) { { id: '123', rawId: '123', type: '123', response: auth_response } }
    let(:auth_response) { { authenticatorData: '123', clientDataJSON: '{}', signature: '123', userHandle: '123' } }

    context 'with valid parameters and a successfull call to FinishAuthentication' do
      let(:agent) { create(:agent) }

      before {
        allow(PasskeysRails::FinishAuthentication)
          .to receive(:call!)
          .and_return(Interactor::Context.build(username: "name", auth_token: "123", agent:))
      }

      it 'Succeeds and returns instance credentails' do
        call_api

        expect_success
        expect(PasskeysRails::FinishAuthentication).to have_received(:call!).exactly(1).time
        expect(json.keys).to match_array %w[username auth_token]
        expect(json).to include(username: "name", auth_token: "123")
      end

      it_behaves_like "a notifier", :did_authenticate
    end

    describe "Unexpected exceptions" do
      context 'with a standard error exception' do
        it "renders the exception in JSON" do
          allow(PasskeysRails::FinishAuthentication).to receive(:call!).and_raise(StandardError.new("This is an exception"))

          call_api

          expect(response.code.to_i).to eq 500

          expect(json[:error]).to be_present
          expect(json[:error][:code]).to eq "error"
          expect(json[:error][:context]).to eq "authentication"
          expect(json[:error][:message]).to eq "This is an exception"
        end
      end
    end
  end
end
