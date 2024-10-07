require Rails.root.join("lib/users/transfer_referent")

namespace :users do
  desc <<-DESC
    This task allows to transfer users from one referent to another
    
    SOURCE_REFERENT_ID=1 TARGET_REFERENT_ID=2  bundle exec rails users:transfer_referent
  DESC
  task transfer_referent: :environment do
    source_referent_id = ENV['SOURCE_REFERENT_ID'].to_i
    target_referent_id = ENV['TARGET_REFERENT_ID'].to_i

    service = Users::TransferReferent.new(source_referent_id:, target_referent_id:)
    service.call

    if service.errors.any?
      puts "Les usagers suivants n'ont pas pu être transférés : #{service.errors.map { |e| e[:user].id }.join(', ')}"
    else
      puts "Tous les usagers ont été transférés avec succès"
    end
  end
end