module Exporters
  class SendUsersParticipationsCsvJob < SendUsersCsvJob
    def generate_csv
      @generate_csv ||= GenerateUsersParticipationsCsv.call(user_ids:, structure:, motif_category:, agent:)
    end
  end
end
