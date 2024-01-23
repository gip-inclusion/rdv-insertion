module Exporters
  class SendUsersParticipationsCsvJob < SendUsersCsvJob
    private

    def generate_csv
      @generate_csv ||= GenerateUsersParticipationsCsv.call(user_ids:, structure:, motif_category:, agent:)
    end

    def send_email(file)
      CsvExportMailer.users_participations_csv_export(agent.email, file).deliver_now
    end
  end
end
