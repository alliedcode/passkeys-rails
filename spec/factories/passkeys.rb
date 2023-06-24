FactoryBot.define do
  factory :passkey, class: "MobilePass::Passkey" do
    agent
    sequence(:identifier) { |i| "identifier #{i}" }
    sequence(:public_key) { |i| "public key #{i}" }
    sign_count { 0 }
  end
end
