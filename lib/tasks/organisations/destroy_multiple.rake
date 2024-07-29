require Rails.root.join("lib/organisations/destroy_multiple")

namespace :organisations do
  desc <<-DESC
    This task allows to destroy multiple organisations by providing their ids as an environment variable.
    
    ORGANISATION_IDS=1,2,3 bundle exec rails organisations:destroy_multiple
  DESC
  task destroy_multiple: :environment do
    organisation_ids = ENV['ORGANISATION_IDS'].split(",").map(&:to_i)
    Organisations::DestroyMultiple.new(organisation_ids:).call
  end
end