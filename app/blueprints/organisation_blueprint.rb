class OrganisationBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :email, :phone_number, :department_number
  association :motif_categories, blueprint: MotifCategoryBlueprint
end
