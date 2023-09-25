class ArchiveBlueprint < Blueprinter::Base
  identifier :id
  fields :archiving_reason, :department_id, :user_id
end
