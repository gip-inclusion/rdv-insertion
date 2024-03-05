class UserBlueprint < Blueprinter::Base
  identifier :id
  fields  :uid, :affiliation_number, :role, :created_at, :department_internal_id,
          :first_name, :last_name, :title, :address, :phone_number, :email, :birth_date, :rights_opening_date,
          :birth_name, :rdv_solidarites_user_id, :nir, :carnet_de_bord_carnet_id, :france_travail_id

  view :with_referents do
    association :referents, blueprint: AgentBlueprint
  end

  view :extended do
    association :organisations, blueprint: OrganisationBlueprint
    association :referents, blueprint: AgentBlueprint
    association :archives, blueprint: ArchiveBlueprint

    association :invitations, blueprint: InvitationBlueprint do |user, _options|
      user.invitations.select do |invitation|
        Pundit.policy!(Current.agent, invitation).show?
      end
    end

    association :rdv_contexts, blueprint: RdvContextBlueprint do |user, _options|
      user.rdv_contexts.select do |rdv_context|
        Pundit.policy!(Current.agent, rdv_context).show?
      end
    end

    association :tags, blueprint: TagBlueprint do |user, _options|
      user.tags.select do |tag|
        Pundit.policy!(Current.agent, tag).show?
      end
    end
  end
end
