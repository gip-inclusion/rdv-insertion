module RdvSolidarites
  class Motif < Base
    RECORD_ATTRIBUTES = [:id, :deleted_at, :location_type, :name, :reservable_online].freeze
    attr_reader(*RECORD_ATTRIBUTES)

    def presential?
      location_type == "public_office"
    end
  end
end
