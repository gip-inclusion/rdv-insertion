class ParticipationBlueprint < ApplicationBlueprint
  identifier :id
  fields :status, :created_at, :starts_at
  association :user, blueprint: UserBlueprint

  # Retrocompatibility with the old API format for created_by
  field :created_by do |participation, _|
    participation.created_by_type.downcase
  end
end
