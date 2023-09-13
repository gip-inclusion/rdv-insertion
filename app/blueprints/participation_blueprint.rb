class ParticipationBlueprint < Blueprinter::Base
  identifier :id
  fields :status, :created_by
  association :applicant, blueprint: ApplicantBlueprint
end
