module RdvSolidarites
  class Lieu < Base
    RECORD_ATTRIBUTES = [:id, :address, :name, :phone_number].freeze
    attr_reader(*RECORD_ATTRIBUTES)

    def ==(other)
      return true if id.nil? && other.nil?
      return false if id.present? && other.nil?

      id == other.rdv_solidarites_lieu_id && address == other.address &&
        name == other.name
    end
  end
end
