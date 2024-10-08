require Rails.root.join("lib/users/transfer_organisation")

namespace :users do
  desc <<-DESC
    This task allows to transfer users from one organisation to another
    with a filter on a specific motif category
    
    SOURCE_ORGANISATION_ID=1 TARGET_ORGANISATION_ID=2 SOURCE_MOTIF_CATEGORY_ID=1 bundle exec rails users:transfer_organisation
  DESC
  task transfer_organisation: :environment do
    source_organisation_id = ENV['SOURCE_ORGANISATION_ID'].to_i
    target_organisation_id = ENV['TARGET_ORGANISATION_ID'].to_i
    source_motif_category_id = ENV['SOURCE_MOTIF_CATEGORY_ID'].to_i

    service = Users::TransferOrganisation.new(source_organisation_id:, target_organisation_id:, source_motif_category_id:)
    service.call

    if service.errors.any?
      puts "Les usagers suivants n'ont pas pu être transférés : #{service.errors { |e| e[:user].id }.join(', ')}"
    else
      puts "Tous les usagers ont été transférés avec succès"
    end
  end
end
