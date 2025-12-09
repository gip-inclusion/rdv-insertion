module Organisations
  module Configuration
    class TagsController < BaseController
      def show
        @user_count_by_tag_id = User.joins(:tags, :organisations)
                                    .where(tags: { id: @department.tags.pluck(:id) })
                                    .where(organisations: { id: @organisation.id })
                                    .distinct
                                    .group(:tag_id)
                                    .count
      end
    end
  end
end
