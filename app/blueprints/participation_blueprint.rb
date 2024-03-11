class ParticipationBlueprint < Blueprinter::Base
  identifier :id
  fields :created_by, :created_at, :starts_at
  field :status do |participation|
    participation.read_attribute(:status)
  end
  association :user, blueprint: UserBlueprint
end
