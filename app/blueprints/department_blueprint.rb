class DepartmentBlueprint < ApplicationBlueprint
  identifier :id
  fields :number, :capital, :region, :carnet_de_bord_deploiement_id

  view :extended do
    association :organisations, blueprint: OrganisationBlueprint, view: :extended
  end
end
