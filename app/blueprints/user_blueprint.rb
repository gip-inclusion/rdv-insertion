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

    association :rdv_contexts, blueprint: RdvContextBlueprint do |user, options|
      if options.key?(:motif_category_ids)
        user.rdv_contexts.select { |rdv_context| rdv_context.motif_category_id.in?(options[:motif_category_ids] || []) }
      else
        user.rdv_contexts
      end
    end

    association :tags, blueprint: TagBlueprint do |user, options|
      if options.key?(:tag_ids)
        user.tags.select { |tag| tag.id.in?(options[:tag_ids] || []) }
      else
        user.tags
      end
    end

    association :referents, blueprint: AgentBlueprint
    association :archives, blueprint: ArchiveBlueprint
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
