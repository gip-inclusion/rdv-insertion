module Exporters
  class ExpireAttachmentJob < ApplicationJob
    def perform(csv_export_id)
      csv_export = CsvExport.find(csv_export_id)
      csv_export.purge!
    end
  end
end
