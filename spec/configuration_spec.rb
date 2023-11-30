RSpec.describe PasskeysRails::Configuration do
  subject(:configuration) { described_class.new }

  it "allows customization auth_token_expires_in" do
    new_value = 1.week

    expect { configuration.auth_token_expires_in = new_value }
      .to change { configuration.auth_token_expires_in }
      .to(new_value)
  end

  it "allows customization auth_token_algorithm" do
    expect { configuration.auth_token_algorithm = "MY ALGORITHM" }
      .to change { configuration.auth_token_algorithm }
      .from("HS256")
      .to("MY ALGORITHM")
  end

  it "allows customization auth_token_secret" do
    expect { configuration.auth_token_secret = "MY SECRET" }
      .to change { configuration.auth_token_secret }
      .from(Rails.application.secret_key_base)
      .to("MY SECRET")
  end

  it "allows customization default_class" do
    expect { configuration.default_class = "AdminUser" }
      .to change { configuration.default_class }
      .from("User")
      .to("AdminUser")
  end

  it "allows customization class_whitelist" do
    expect { configuration.class_whitelist = %w[User AdminUser] }
      .to change { configuration.class_whitelist }
      .from(nil)
      .to match_array(%w[User AdminUser])
  end
end
