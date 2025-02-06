module RdvSolidarites
  class Rdv < Base
    RECORD_ATTRIBUTES = [
      :id, :address, :cancelled_at, :context, :created_by, :duration_in_min, :starts_at, :status,
      :uuid, :users_count, :max_participants_count
    ].freeze
    attr_reader(*RECORD_ATTRIBUTES)

    delegate :presential?, :collectif?, :motif_category, to: :motif

    def initialize(attributes = {})
      super
    end

    def users
      @attributes[:users].map { RdvSolidarites::User.new(_1) }.reject(&:deleted?)
    end

    def participations
      @attributes[:participations].map do |participation_attributes|
        RdvSolidarites::Participation.new(participation_attributes.merge(rdv: @attributes))
      end
    end

    def participation_for(user)
      participations.find { _1.user.id == user.rdv_solidarites_user_id }
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
