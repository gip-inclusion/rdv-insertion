class UserBlueprint < Blueprinter::Base
  identifier :id
  fields  :uid, :affiliation_number, :role, :created_at, :department_internal_id,
          :first_name, :last_name, :title, :address, :phone_number, :email, :birth_date, :rights_opening_date,
          :birth_name, :rdv_solidarites_user_id, :nir, :pole_emploi_id, :carnet_de_bord_carnet_id

  view :with_referents do
    association :referents, blueprint: AgentBlueprint
  end

  view :extended do
    association :invitations, blueprint: InvitationBlueprint
    association :organisations, blueprint: OrganisationBlueprint
    association :rdv_contexts, blueprint: RdvContextBlueprint
    association :referents, blueprint: AgentBlueprint
    association :archives, blueprint: ArchiveBlueprint
    association :tags, blueprint: TagBlueprint
  end

  view :searches do
    include_view :extended
    include_view :with_referents

    exclude :rdv_solidarites_user_id
    exclude :title
    exclude :birth_date
    exclude :birth_name
    exclude :pole_emploi_id
  end
end
