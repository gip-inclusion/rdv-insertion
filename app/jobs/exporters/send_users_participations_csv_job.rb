module Exporters
  class SendUsersParticipationsCsvJob < SendUsersCsvJob
    def generate_csv
      @generate_csv ||= GenerateUsersParticipationsCsv.call(user_ids:, structure:, motif_category:, agent:)
    end

    def send_csv
      CsvExportMailer.users_participations_csv_export(agent.email, generate_csv.csv, generate_csv.filename).deliver_now
    end
  end
end
