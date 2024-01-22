module Exporters
  class SendUsersCsvJob < ApplicationJob
    attr_reader :user_ids, :structure, :motif_category, :agent

    def perform(user_ids, structure_type, structure_id, motif_category_id, agent_id)
      @user_ids = user_ids
      @structure = structure_type.constantize.find(structure_id)
      @motif_category = motif_category_id.present? ? MotifCategory.find(motif_category_id) : nil
      @agent = Agent.find(agent_id)

      ZipFile.new(generate_csv.csv, generate_csv.filename).zip do |file|
        send_email(file)
      end
    end

    private

    def send_email(file)
      CsvExportMailer.users_csv_export(agent.email, file).deliver_now
    end

    def generate_csv
      @generate_csv ||= GenerateUsersCsv.call(user_ids:, structure:, motif_category:, agent:)
    end
  end
end
