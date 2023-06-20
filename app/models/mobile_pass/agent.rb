module MobilePass
  class Agent < ApplicationRecord
    belongs_to :authenticatable, polymorphic: true
  end
end
