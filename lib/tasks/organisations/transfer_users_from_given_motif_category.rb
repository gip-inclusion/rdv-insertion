require Rails.root.join("lib/organisations/transfer_users_from_given_motif_category")

namespace :organisations do
  desc <<-DESC
    This task allows to transfer users from a given motif category and a given organisation 
    to the same motif in another organisation.

    SOURCE_ORGANISATION_ID=29 TARGET_ORGANISATION_ID=483 MOTIF_CATEGORY_ID=37   bundle exec rails organisations:transfer_users_from_given_motif_category
  DESC

  task transfer_users_from_given_motif_category: :environment do
    source_organisation_id = ENV['SOURCE_ORGANISATION_ID']
    target_organisation_id = ENV['TARGET_ORGANISATION_ID']
    motif_category_id = ENV['MOTIF_CATEGORY_ID']

    Organisations::TransferUsersFromGivenMotifCategory.new(
      source_organisation_id: source_organisation_id,
      target_organisation_id: target_organisation_id,
      motif_category_id: motif_category_id
    ).perform
  end
end


