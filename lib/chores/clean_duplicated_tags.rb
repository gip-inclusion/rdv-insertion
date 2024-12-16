module Chores
  class CleanDuplicatedTags
    def self.call
      duplicates = TagUser
        .select('tag_id, user_id')
        .group(:tag_id, :user_id)
        .having('COUNT(*) > 1')
        .pluck(:tag_id, :user_id)

      duplicates.each do |tag_id, user_id|
        records = TagUser.where(tag_id: tag_id, user_id: user_id).order(:created_at)

        # Keep the first record and delete the others
        records[1..-1].each(&:destroy)
      end
    end
  end
end
