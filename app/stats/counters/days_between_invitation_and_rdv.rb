module Counters
  class DaysBetweenInvitationAndRdv
    include Statisfy::Aggregate

    aggregate every: :participation_created,
              value: -> { participation.rdv_context.time_between_invitation_and_rdv_in_days },
              if: lambda {
                participation.rdv_context.participations.pluck(:id).min == participation.id &&
                  participation.rdv_context.invitations.present? &&
                  participation.rdv_context.time_between_invitation_and_rdv_in_days.present? &&
                  participation.rdv_context.time_between_invitation_and_rdv_in_days >= 0
              },
              date_override: -> { participation.rdv_context["created_at"] }
  end
end
