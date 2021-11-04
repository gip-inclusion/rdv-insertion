class Notification < ApplicationRecord
  belongs_to :applicant
  delegate :organisation, to: :applicant

  enum event: { rdv_created: 0, rdv_updated: 1, rdv_cancelled: 2, rdv_destroyed: 3 }
end
