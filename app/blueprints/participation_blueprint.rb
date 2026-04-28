class ParticipationBlueprint < ApplicationBlueprint
  identifier :id
  fields :status, :created_at

  field :starts_at do |participation, _options|
    participation.starts_at_in_time_zone
  end

  association :user, blueprint: UserBlueprint

  # Retrocompatibility with the old API format for created_by
  field :created_by do |participation, _|
    participation.created_by_type.downcase
  end
end
