class User < ApplicationRecord
  include PasskeysRails::Authenticatable
end
