require "stringio"

module Exporters
  class SendUsersCsvJob < ApplicationJob
    attr_reader :user_ids, :structure, :motif_category, :agent

    def perform(user_ids, structure_type, structure_id, motif_category_id, agent_id)
      @user_ids = user_ids
      @structure = structure_type.constantize.find(structure_id)
      @motif_category = motif_category_id.present? ? MotifCategory.find(motif_category_id) : nil
      @agent = Agent.find(agent_id)

      send_email
    end

    private

    def csv_export
      export = CsvExport.create!(agent:, structure:, kind: self.class.name.demodulize.underscore)
      export.file.attach(io: StringIO.new(generate_csv.csv), filename: generate_csv.filename, content_type: "text/csv")
      export
    end

    def send_email
      CsvExportMailer.users_csv_export(agent.email, csv_export).deliver_now
    end

    def generate_csv
      @generate_csv ||= GenerateUsersCsv.call(user_ids:, structure:, motif_category:, agent:)
    end
  end
end
