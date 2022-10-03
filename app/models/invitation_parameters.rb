class InvitationParameters < ApplicationRecord
  has_many :organisations, dependent: :nullify
end
