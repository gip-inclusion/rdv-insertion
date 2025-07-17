namespace :participations do
  task migrate_created_by: :environment do
    MigrateParticipationsCreatedByJob.perform_later
  end
end