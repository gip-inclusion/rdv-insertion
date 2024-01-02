module Exporters
  class GenerateParticipationsCsv < GenerateUsersCsv
    private

    def each_element(&)
      @elements.find_each do |element|
        element.participations
               .to_a
               .each(&)
      end
    end

    def preload_associations
      @elements =
        if @motif_category
          @elements.preload(:archives, :tags, :referents, :organisations)
        else
          @elements.preload(:invitations, :notifications, :archives, :organisations, :tags, :referents)
        end

      @elements = @elements.preload(
        participations: [
          :organisation,
          {
            rdv_context: [
              :invitations,
              :notifications,
              { rdvs: [:motif, :organisation, :participations, :users] }
            ]
          }
        ]
      )
    end

    def headers # rubocop:disable Metrics/AbcSize
      [User.human_attribute_name(:title),
       User.human_attribute_name(:last_name),
       User.human_attribute_name(:first_name),
       User.human_attribute_name(:affiliation_number),
       User.human_attribute_name(:department_internal_id),
       User.human_attribute_name(:nir),
       User.human_attribute_name(:pole_emploi_id),
       User.human_attribute_name(:email),
       User.human_attribute_name(:address),
       User.human_attribute_name(:phone_number),
       User.human_attribute_name(:birth_date),
       User.human_attribute_name(:created_at),
       User.human_attribute_name(:rights_opening_date),
       User.human_attribute_name(:role),
       "Première invitation envoyée le",
       "Dernière invitation envoyée le",
       "Dernière convocation envoyée le",
       "Date du RDV",
       "Heure du RDV",
       "Motif du RDV",
       "Nature du RDV",
       "Dernier RDV pris en autonomie ?",
       Rdv.human_attribute_name(:status),
       *(RdvContext.human_attribute_name(:status) if @motif_category),
       "1er RDV honoré en - de 30 jours ?",
       "Date d'orientation",
       Archive.human_attribute_name(:created_at),
       Archive.human_attribute_name(:archiving_reason),
       User.human_attribute_name(:referents),
       "Nombre d'organisations",
       "Organisation du rendez-vous",
       User.human_attribute_name(:tags)]
    end

    def csv_row(participation) # rubocop:disable Metrics/AbcSize
      user = participation.user

      [user.title,
       user.last_name,
       user.first_name,
       user.affiliation_number,
       user.department_internal_id,
       user.nir,
       user.pole_emploi_id,
       user.email,
       user.address,
       user.phone_number,
       display_date(user.birth_date),
       display_date(user.created_at),
       display_date(user.rights_opening_date),
       user.role,
       display_date(participation.rdv_context.first_invitation_sent_at),
       display_date(participation.rdv_context.last_invitation_sent_at),
       display_date(participation.rdv_context.last_sent_convocation_sent_at),
       display_date(rdv_date(participation)),
       display_time(rdv_date(participation)),
       rdv_motif(participation),
       rdv_type(participation),
       rdv_taken_in_autonomy?(participation),
       human_status(participation),
       *(human_rdv_context_status(participation) if @motif_category),
       rdv_seen_in_less_than_30_days?(user),
       display_date(user.first_seen_rdv_starts_at),
       display_date(user.archive_for(department_id)&.created_at),
       user.archive_for(department_id)&.archiving_reason,
       user.referents.map(&:email).join(", "),
       user.organisations.to_a.count,
       participation.organisation.name,
       user.tags.pluck(:value).join(", ")]
    end

    def resource_human_name
      "participations"
    end

    def rdv_date(participation)
      participation.rdv.starts_at
    end

    def rdv_motif(participation)
      participation.rdv.motif&.name || ""
    end

    def rdv_taken_in_autonomy?(participation)
      I18n.t("boolean.#{participation.created_by_user?}")
    end

    def rdv_type(participation)
      participation.rdv.collectif? ? "collectif" : "individuel"
    end

    def human_status(participation)
      I18n.t("activerecord.attributes.rdv.statuses.#{participation.status}")
    end

    def human_rdv_context_status(participation)
      I18n.t("activerecord.attributes.rdv_context.statuses.#{participation.rdv_context.status}") +
        display_context_status_notice(participation.rdv_context)
    end
  end
end
