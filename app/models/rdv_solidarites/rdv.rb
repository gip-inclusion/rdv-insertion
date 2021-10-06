module RdvSolidarites
  class Rdv < Base
    RECORD_ATTRIBUTES = [
      :id, :address, :cancelled_at, :context, :created_by, :duration_in_min, :starts_at, :status,
      :uuid, :rdv_solidarites_motif_id, :rdv_solidarites_lieu_id
    ].freeze
    attr_reader(*RECORD_ATTRIBUTES)

    delegate :presential?, to: :motif

    def initialize(attributes = {})
      attributes[:rdv_solidarites_lieu_id] ||= attributes.dig('lieu', 'id')
      attributes[:rdv_solidarites_motif_id] ||= attributes.dig('motif', 'id')
      super(attributes)
    end

    def users
      @attributes[:users].map { RdvSolidarites::User.new(_1) }
    end

    def lieu
      @attributes[:lieu].present? ? RdvSolidarites::Lieu.new(@attributes[:lieu]) : nil
    end

    def motif
      RdvSolidarites::Motif.new(@attributes[:motif])
    end

    def agents
      @attributes[:agents].map { RdvSolidarites::Agent.new(_1) }
    end

    def user_ids
      users.map(&:id)
    end

    def formatted_start_date
      starts_at.to_datetime.strftime("%d/%m/%Y")
    end

    def formatted_start_time
      starts_at.to_datetime.strftime('%H:%M')
    end
  end
end
