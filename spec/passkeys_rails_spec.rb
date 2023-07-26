RSpec.describe PasskeysRails do
  it "has a version number" do
    expect(PasskeysRails::VERSION).not_to be_nil
  end

  it "allows customization auth_token_expires_in" do
    new_value = 1.week

    expect { described_class.auth_token_expires_in = new_value }
      .to change { described_class.auth_token_expires_in }
      .to(new_value)
  end

  it "allows customization auth_token_algorithm" do
    expect { described_class.auth_token_algorithm = "MY ALGORITHM" }
      .to change { described_class.auth_token_algorithm }
      .from("HS256")
      .to("MY ALGORITHM")
  end

  it "allows customization auth_token_secret" do
    expect { described_class.auth_token_secret = "MY SECRET" }
      .to change { described_class.auth_token_secret }
      .from(Rails.application.secret_key_base)
      .to("MY SECRET")
  end

  it "allows customization default_class" do
    expect { described_class.default_class = "AdminUser" }
      .to change { described_class.default_class }
      .from("User")
      .to("AdminUser")
  end

  it "allows customization class_whitelist" do
    expect { described_class.class_whitelist = %w[User AdminUser] }
      .to change { described_class.class_whitelist }
      .from(nil)
      .to match_array(%w[User AdminUser])
  end
end
