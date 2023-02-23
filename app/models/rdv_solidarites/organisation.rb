module RdvSolidarites
  class Organisation < Base
    RECORD_ATTRIBUTES = [:id, :name, :phone_number, :email].freeze
    attr_reader(*RECORD_ATTRIBUTES)

    def organisation
      @organisation ||= Organisation.find_by(rdv_solidarites_organisation_id: @id)
    end
  end
end
