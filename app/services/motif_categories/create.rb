module MotifCategories
  class Create < BaseService
    def initialize(motif_category:)
      @motif_category = motif_category
    end

    def call
      MotifCategory.transaction do
        save_record!(@motif_category)
        create_rdvs_motif_category
      end
    end

    private

    def create_rdvs_motif_category
      @create_rdvs_motif_category ||= call_service!(
        RdvSolidaritesApi::CreateMotifCategory,
        motif_category_attributes:
          @motif_category.attributes.symbolize_keys.slice(*MotifCategory::SHARED_ATTRIBUTES_WITH_RDV_SOLIDARITES)
      )
    end
  end
end
