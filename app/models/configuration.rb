class Configuration < ApplicationRecord
  belongs_to :department

  enum invitation_format: { sms: 0, email: 1, link_only: 2, no_invitation: 3 }
end
