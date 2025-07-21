class CookiesConsent < ApplicationRecord
  belongs_to :agent

  validates :support_accepted, :tracking_accepted, inclusion: { in: [true, false] }
  validates :agent_id, uniqueness: true
end
