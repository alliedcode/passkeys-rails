module Passkeys::Rails
  class Passkey < ApplicationRecord
    belongs_to :agent
    validates :identifier, presence: true, uniqueness: true
    validates :public_key, presence: true
    validates :sign_count, presence: true
  end
end
