module Api
  module V1
    module PaperTrailConcern
      extend ActiveSupport::Concern

      included do
        before_action :set_paper_trail_whodunnit
      end

      private

      def user_for_paper_trail
        "[Agent via API] #{current_agent.name_for_paper_trail}"
      end
    end
  end
end
