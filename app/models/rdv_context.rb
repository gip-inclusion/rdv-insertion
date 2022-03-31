class RdvContext < ApplicationRecord
  include HasContextConcern
  include HasContextStatusConcern

  has_many :invitations, dependent: :destroy
  has_and_belongs_to_many :rdvs
  belongs_to :applicant

  validates :context, uniqueness: { scope: :applicant_id }
end
