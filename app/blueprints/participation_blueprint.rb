class ParticipationBlueprint < Blueprinter::Base
  identifier :id
  fields :status, :created_by, :created_at
  association :user, blueprint: UserBlueprint
end
