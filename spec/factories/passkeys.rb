FactoryBot.define do
  factory :passkey, class: "PasskeysRails::Passkey" do
    agent
    sequence(:identifier) { |i| "identifier #{i}" }
    sequence(:public_key) { |i| "public key #{i}" }
    sign_count { 0 }
  end
end
