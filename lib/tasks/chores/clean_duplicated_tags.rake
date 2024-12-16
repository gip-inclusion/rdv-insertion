require Rails.root.join("lib/chores/clean_duplicated_tags")

namespace :chores do
  desc "Remove all duplicate tag-user combinations"
  task remove_duplicates: :environment do
    CleanDuplicatedTags.call
  end
end