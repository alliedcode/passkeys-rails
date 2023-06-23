module MobilePass
  class Agent < ApplicationRecord
    belongs_to :authenticatable, polymorphic: true, optional: true
    has_many :passkeys

    scope :registered, -> { where.not registered_at: nil }
    scope :unregistered, -> { where registered_at: nil }

    validates :username, presence: true, uniqueness: true

    def registered?
      registered_at.present?
    end
  end
end
