module FollowUps
  class CleanUnused < BaseService
    # This service is used to clean the follow_ups of a user
    # when he is no longer member of an organisation that handle this motif_category
    def initialize(user:)
      @user = user
    end

    def call
      @user.follow_ups.each do |follow_up|
        next if follow_up.status != "not_invited"
        next if @user.organisations.any? do |organisation|
          organisation.motif_categories.include?(follow_up.motif_category)
        end

        follow_up.destroy!
      end
    end
  end
end
