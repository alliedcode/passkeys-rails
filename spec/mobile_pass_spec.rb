RSpec.describe MobilePass do
  it "has a version number" do
    expect(MobilePass::VERSION).not_to be_nil
  end

  it "allows customization auth_token_expiration" do
    new_value = 1.week.from_now

    expect { described_class.auth_token_expiration = new_value }
      .to change { described_class.auth_token_expiration.to_i }
      .to(new_value.to_i)
  end

  it "allows customization parent_controller" do
    expect { described_class.parent_controller = "MyController" }
      .to change { described_class.parent_controller }
      .from("ApplicationController")
      .to("MyController")
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
