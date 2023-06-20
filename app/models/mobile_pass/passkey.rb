module MobilePass
  class Passkey < ApplicationRecord
    belongs_to :agent
  end
end
