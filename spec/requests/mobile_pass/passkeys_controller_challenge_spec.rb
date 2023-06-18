RSpec.describe MobilePass::PasskeysController do
  it 'does some testing' do
    post '/challenge', params: { username: 'jerry' }
    expect(response.body).to eq "Troy"
    expect(response).to be_successful
  end
end
