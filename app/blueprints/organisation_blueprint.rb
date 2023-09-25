class OrganisationBlueprint < Blueprinter::Base
  # To delete after BDR make the change
  if ENV["ROLLOUT_NEW_API_VERSION"] == "1"
    identifier :id
  else
    identifier :rdv_solidarites_organisation_id, name: :id
  end
  fields :name, :email, :phone_number

  view :extended do
    fields :department_number
    association :motif_categories, blueprint: MotifCategoryBlueprint
  end
end
