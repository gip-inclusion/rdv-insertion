module RdvSolidarites
  class Participation < Base
    RECORD_ATTRIBUTES = [
      :id, :status, :user
    ].freeze
    attr_reader(*RECORD_ATTRIBUTES)

    def to_rdv_insertion_attributes
      attributes.merge(rdv_solidarites_participation_id: id)
    end
  end
end
