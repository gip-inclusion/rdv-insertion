class Invitation < ApplicationRecord
  belongs_to :applicant
  delegate :department, to: :applicant

  enum format: { sms: 0, email: 1, link_only: 2 }

  def as_json(_opts = {})
    super.merge(sent_at: sent_at&.to_date&.strftime("%m/%d/%Y"))
  end
end
