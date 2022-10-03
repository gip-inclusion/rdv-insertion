class Notification < ApplicationRecord
  belongs_to :applicant

  # when a rdv is destroyed a convocation will still be sent
  belongs_to :rdv, optional: true

  enum event: { rdv_created: 0, rdv_updated: 1, rdv_cancelled: 2 }

  enum format: { sms: 0, email: 1 }

  scope :convocations, -> { where(convocation: true) }
end
