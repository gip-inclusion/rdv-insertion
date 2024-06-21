module Exporters
  class ExpireAttachmentJob < ApplicationJob
    def perform(csv_export_id)
      csv_export = CsvExport.find_by(id: csv_export_id)
      return unless csv_export

      csv_export.purge!
    end
  end
end
