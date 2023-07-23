FactoryBot.define do
  factory :agent, class: "Passkeys::Rails::Agent" do
    sequence(:username) { |n| "username-#{n}" }
    registered_at { nil }
    last_authenticated_at { nil }

    trait :registered do
      registered_at { 1.day.ago }
    end

    trait :unregistered do
      registered_at { nil }
    end

    trait :recentyl_authenticated do
      last_authenticated_at { 2.hours.ago }
    end
  end
end
