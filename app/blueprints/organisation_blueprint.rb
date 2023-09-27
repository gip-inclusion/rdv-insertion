class OrganisationBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :email, :phone_number

  view :extended do
    fields :department_number
    association :motif_categories, blueprint: MotifCategoryBlueprint
  end
end
