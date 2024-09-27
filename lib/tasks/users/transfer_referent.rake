require Rails.root.join("lib/users/transfer_referent")

namespace :users do
  desc <<-DESC
    This task allows to transfer users from one referent to another
    
    SOURCE_REFERENT_ID=1 TARGET_REFERENT_ID=2  bundle exec rails users:transfer_referent
  DESC
  task transfer_referent: :environment do
    source_referent_id = ENV['SOURCE_REFERENT_ID'].to_i
    target_referent_id = ENV['TARGET_REFERENT_ID'].to_i

    Users::TransferReferent.new(source_referent_id:, target_referent_id:).call
  end
end