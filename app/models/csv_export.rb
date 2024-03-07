class CsvExport < ApplicationRecord
  belongs_to :agent
  belongs_to :structure, polymorphic: true

  has_one_attached :file

  enum kind: { users_csv: 0, users_participations_csv: 1 }

  VALIDITY_PERIOD = 2.days

  after_create do
    Exporters::ExpireAttachmentJob.perform_in(VALIDITY_PERIOD, id)
  end

  def expired?
    created_at < VALIDITY_PERIOD.ago
  end
end
