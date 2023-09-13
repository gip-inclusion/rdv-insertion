class OrganisationBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :email, :phone_number
end
