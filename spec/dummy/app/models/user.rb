class User < ApplicationRecord
  include MobilePass::Authenticatable
end
