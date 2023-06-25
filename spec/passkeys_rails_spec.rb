RSpec.describe PasskeysRails do
  after {
    # Restore defaults so other specs aren't affected
    PasskeysRails.config do |c|
      c.auth_token_secret = Rails.application.secret_key_base
      c.auth_token_algorithm = "HS256"
      c.auth_token_expires_in = 30.days
    end
  }

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
end
