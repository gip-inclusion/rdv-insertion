module RdvSolidarites
  class Motif < Base
    RECORD_ATTRIBUTES = [
      :id, :deleted_at, :location_type, :name, :bookable_by, :service_id, :collectif, :follow_up,
      :instruction_for_rdv, :default_duration_in_min
    ].freeze
    attr_reader(*RECORD_ATTRIBUTES)

    def presential?
      location_type == "public_office"
    end

    def convocation?
      name.downcase.include?("convocation")
    end

    def collectif?
      collectif == true
    end

    def name_with_location_type
      "#{name}-#{location_type}"
    end

    def visio?
      location_type == "visio"
    end

    def motif_category
      if @attributes[:motif_category].blank?
        nil
      else
        RdvSolidarites::MotifCategory.new(@attributes[:motif_category])
      end
    end

    def to_rdv_insertion_attributes
      attributes.merge(rdv_solidarites_service_id: service_id)
    end
  end
end
