class OrganisationBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :email, :phone_number, :department_number, :rdv_solidarites_organisation_id
  association :motif_categories, blueprint: MotifCategoryBlueprint
end
