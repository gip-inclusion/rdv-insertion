class DepartmentBlueprint < ApplicationBlueprint
  identifier :id
  fields :number, :capital, :region

  view :extended do
    association :organisations, blueprint: OrganisationBlueprint, view: :extended
  end
end
