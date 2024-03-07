module Exporters
  class CreateUsersParticipationsCsvExportJob < CreateUsersCsvExportJobJob
    EXPORT_KIND = :users_participations_csv

    private

    def generate_csv
      @generate_csv ||= GenerateUsersParticipationsCsv.call(user_ids:, structure:, motif_category:, agent:)
    end
  end
end
