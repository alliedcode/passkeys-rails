RSpec.describe MobilePass::PasskeysController do
  it 'does some testing' do
    post '/mobile_pass/passkeys/challenge', params: { username: 'jerry' }
    expect(response.body).to eq "Troy"
    expect(response).to be_successful
  end
end

# routes
# mobile_pass_for :users
