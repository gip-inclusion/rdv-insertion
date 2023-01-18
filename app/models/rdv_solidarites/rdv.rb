module RdvSolidarites
  class Rdv < Base
    RECORD_ATTRIBUTES = [
      :id, :address, :cancelled_at, :context, :created_by, :duration_in_min, :starts_at, :status,
      :uuid
    ].freeze
    attr_reader(*RECORD_ATTRIBUTES)

    delegate :presential?, :category, to: :motif

    def initialize(attributes = {})
      super(attributes)
    end

    def users
      @attributes[:users].map { RdvSolidarites::User.new(_1) }
    end

    def participations
      @attributes[:rdvs_users].map { RdvSolidarites::Participation.new(_1) }
    end

    # rubocop:disable Rails/Delegate
    def motif_id
      motif.id
    end
    # rubocop:enable Rails/Delegate

    def lieu_id
      lieu&.id
    end

    def lieu
      @attributes[:lieu].present? ? RdvSolidarites::Lieu.new(@attributes[:lieu]) : nil
    end

    def motif
      RdvSolidarites::Motif.new(@attributes[:motif])
    end

    def convocable?
      motif.convocation?
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
      starts_at.to_datetime.strftime("%H:%M")
    end
  end
end
