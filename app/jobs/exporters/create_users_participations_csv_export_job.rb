module Exporters
  class CreateUsersParticipationsCsvExportJob < CreateUsersCsvExportJob
    private

    def generate_csv
      @generate_csv ||= GenerateUsersParticipationsCsv.call(
        user_ids:, structure:, motif_category_id: motif_category_id, agent:
      )
    end

    def export_kind
      :users_participations_csv
    end
  end
end
