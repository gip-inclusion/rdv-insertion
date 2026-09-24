module PlateformeInclusion
  class UserBlueprint < ApplicationBlueprint
    identifier :id
    fields :affiliation_number, :role, :created_at, :department_internal_id,
           :first_name, :last_name, :title, :address, :phone_number, :email, :birth_date, :rights_opening_date,
           :birth_name, :rdv_solidarites_user_id, :nir, :france_travail_id

    association :referents, blueprint: AgentBlueprint
    association :tags, blueprint: TagBlueprint
    association :follow_ups, blueprint: FollowUpBlueprint, view: :plateforme_inclusion

    field :organisations do |user, options|
      user.organisations.map do |organisation|
        OrganisationBlueprint.render_as_json(organisation, options.merge(view: :without_motif_categories))
                             .merge(user_archived_at: user.archive_in_organisation(organisation)&.created_at)
      end
    end
  end
end
