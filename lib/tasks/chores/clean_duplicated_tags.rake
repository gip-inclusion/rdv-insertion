require Rails.root.join("lib/chores/clean_duplicated_tags")

namespace :chores do
  desc "Remove all duplicate tag-user combinations"
  task clean_duplicated_tags: :environment do
    Chores::CleanDuplicatedTags.call
  end
end