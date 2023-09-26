class ParticipationBlueprint < Blueprinter::Base
  identifier :id
  fields :status, :created_by
  association :user, blueprint: UserBlueprint
end
