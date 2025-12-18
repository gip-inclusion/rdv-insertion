module Organisations
  module CategoryConfigurations
    class MotifsController < BaseController
      def index
        @motifs = @organisation.motifs.where(motif_category_id: @category_configuration.motif_category_id)
      end
    end
  end
end
