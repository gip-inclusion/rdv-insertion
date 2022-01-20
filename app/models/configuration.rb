class Configuration < ApplicationRecord
  belongs_to :organisation
  belongs_to :department, optional: true

  enum invitation_format: { sms: 0, email: 1, sms_and_email: 2, link_only: 3, no_invitation: 4 }
end
