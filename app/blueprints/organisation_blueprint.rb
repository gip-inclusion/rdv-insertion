class OrganisationBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :email, :phone_number, :department_number, :rdv_solidarites_organisation_id
  association :motif_categories, blueprint: MotifCategoryBlueprint

  view :extended do
    association :motifs, blueprint: MotifBlueprint
    association :lieux, blueprint: LieuBlueprint
  end
end
