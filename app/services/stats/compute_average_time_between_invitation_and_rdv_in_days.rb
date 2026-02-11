module Stats
  class ComputeAverageTimeBetweenInvitationAndRdvInDays < BaseService
    def initialize(structure: nil, range: nil)
      @structure = structure
      @range = range
    end

    def call
      result.value = compute_average_time_between_invitation_and_rdv_in_days
    end

    private

    def structure_filter
      return "" if @structure.nil?

      if @structure.is_a?(Department)
        "WHERE invitations.department_id = #{@structure.id}"
      else
        <<~SQL.squish
          JOIN invitations_organisations io ON invitations.id = io.invitation_id
          WHERE io.organisation_id = #{@structure.id}
        SQL
      end
    end

    def date_filter
      return "" if @range.nil?

      "HAVING MIN(created_at) >= '#{@range.begin}' AND MIN(created_at) <= '#{@range.end}'"
    end

    def query
      <<~SQL.squish
        WITH first_invitations AS (
            SELECT
                follow_up_id,
                MIN(created_at) AS first_invitation_at
            FROM invitations
            #{structure_filter}
            GROUP BY follow_up_id
            #{date_filter}
        ),
        first_participations AS (
            SELECT
                follow_up_id,
                MIN(created_at) AS first_participation_at
            FROM participations
            GROUP BY follow_up_id
        )
        SELECT
            AVG(duration_in_days) AS average_duration_in_days
        FROM (
            SELECT
                fi.follow_up_id,
                fi.first_invitation_at,
                DATE_PART('days', fp.first_participation_at - fi.first_invitation_at) AS duration_in_days
            FROM first_invitations fi
            LEFT JOIN first_participations fp ON fi.follow_up_id = fp.follow_up_id
            WHERE fp.follow_up_id IS NOT NULL
                AND fi.first_invitation_at IS NOT NULL
                AND fp.first_participation_at >= fi.first_invitation_at
        ) as subquery
      SQL
    end

    def compute_average_time_between_invitation_and_rdv_in_days
      ActiveRecord::Base.connection.execute(query)[0]["average_duration_in_days"] || 0
    end
  end
end
