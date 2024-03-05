module Exporters
  class ExpireAttachmentJob < ApplicationJob
    def perform(csv_export_id)
      csv_export = CsvExport.find(csv_export_id)
      csv_export.file.purge
    end
  end
end
