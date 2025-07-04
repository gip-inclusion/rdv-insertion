class ParticipationBlueprint < ApplicationBlueprint
  identifier :id
  fields :status, :created_at, :starts_at, :created_by_type, :created_by_agent_prescripteur,
         :rdv_solidarites_created_by_id
  association :user, blueprint: UserBlueprint

  # Retrocompatibility with the old API format for created_by
  field :created_by do |participation, _|
    participation.created_by_type.downcase
  end
end
