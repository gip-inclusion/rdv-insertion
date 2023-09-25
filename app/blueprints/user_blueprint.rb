class UserBlueprint < Blueprinter::Base
  # To delete after BDR make the change
  if ENV["ROLLOUT_NEW_API_VERSION"] == "1"
    identifier :id
  else
    identifier :rdv_solidarites_user_id, name: :id
  end

  fields  :uid, :affiliation_number, :role, :created_at, :department_internal_id,
          :first_name, :last_name, :title, :address, :phone_number, :email, :birth_date, :rights_opening_date,
          :birth_name, :deleted_at, :birth_name, :nir, :pole_emploi_id, :carnet_de_bord_carnet_id

  view :extended do
    association :invitations, blueprint: InvitationBlueprint
    association :rdv_contexts, blueprint: RdvContextBlueprint
    association :referents, blueprint: AgentBlueprint
    association :archives, blueprint: ArchiveBlueprint
    association :tags, blueprint: TagBlueprint
  end
end
