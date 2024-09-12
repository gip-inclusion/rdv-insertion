module Stats
  module GlobalStats
    class UpsertStatsJob < ApplicationJob
      def perform
        upsert_stat("Department", nil)

        Department.find_each do |department|
          upsert_stat("Department", department.id)
        end

        Organisation.find_each do |organisation|
          upsert_stat("Organisation", organisation.id)
        end
      end

      private

      def upsert_stat(structure_type, structure_id)
        Stat::GLOBAL_STAT_ATTRIBUTES.each do |method_name|
          Stats::GlobalStats::UpsertStatJob.perform_later(structure_type, structure_id, method_name)
        end
      end
    end
  end
end
