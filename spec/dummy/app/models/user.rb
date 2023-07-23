class User < ApplicationRecord
  include Passkeys::Rails::Authenticatable
end
