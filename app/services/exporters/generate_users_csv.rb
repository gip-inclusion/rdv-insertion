require "csv"

# rubocop:disable Metrics/ClassLength
module Exporters
  class GenerateUsersCsv < BaseService
    def initialize(users:, structure: nil, motif_category: nil)
      @users = users
      @structure = structure
      @motif_category = motif_category
    end

    def call
      result.filename = filename
      result.csv = generate_csv
    end

    private

    def generate_csv
      csv = CSV.generate(write_headers: true, col_sep: ";", headers: headers, encoding: "utf-8") do |row|
        @users.preload(:invitations, :notifications, :archives, :organisations, :tags, :referents, :notifications,
                       :participations, rdvs: [:motif, :participations, :users])
              .preload(rdv_contexts: [rdvs: [:motif, :participations, :users]])
              .each do |user|
          row << user_csv_row(user)
        end
      end
      # We add a BOM at the beginning of the file to enable a correct parsing of accented characters in Excel
      "\uFEFF#{csv}"
    end

    def headers
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
       "Date du dernier RDV",
       "Heure du dernier RDV",
       "Motif du dernier RDV",
       "Nature du dernier RDV",
       "Dernier RDV pris en autonomie ?",
       User.human_attribute_name(:status),
       "1er RDV honoré en - de 30 jours ?",
       "Date d'orientation",
       Archive.human_attribute_name(:created_at),
       Archive.human_attribute_name(:archiving_reason),
       User.human_attribute_name(:referents),
       "Nombre d'organisations",
       "Nom des organisations",
       User.human_attribute_name(:tags)]
    end

    def user_csv_row(user) # rubocop:disable Metrics/AbcSize
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
       display_date(first_invitation_date(user)),
       display_date(last_invitation_date(user)),
       display_date(last_notification_date(user)),
       display_date(last_rdv_date(user)),
       display_time(last_rdv_date(user)),
       last_rdv_motif(user),
       last_rdv_type(user),
       rdv_taken_in_autonomy?(user),
       human_status(user),
       rdv_seen_in_less_than_30_days?(user),
       display_date(user.first_seen_rdv_starts_at),
       display_date(user.archive_for(department_id)&.created_at),
       user.archive_for(department_id)&.archiving_reason,
       user.referents.map(&:email).join(", "),
       user.organisations.to_a.count,
       user.organisations.map(&:name).join(", "),
       user.tags.pluck(:value).join(", ")]
    end

    def filename
      if @structure.present?
        "Export_beneficiaires_#{@motif_category.present? ? "#{@motif_category.short_name}_" : ''}" \
          "#{@structure.class.model_name.human.downcase}_" \
          "#{@structure.name.parameterize(separator: '_')}.csv"
      else
        "Export_beneficiaires_#{Time.zone.now.to_i}.csv"
      end
    end

    def human_status(user)
      return "Archivé" if user.archive_for(department_id).present?

      if @motif_category.present? && rdv_context(user).present?
        I18n.t("activerecord.attributes.rdv_context.statuses.#{rdv_context(user).status}") +
          display_context_status_notice(rdv_context(user))
      elsif last_rdv(user).present?
        I18n.t("activerecord.attributes.rdv.statuses.#{last_rdv(user).status}")
      else
        ""
      end
    end

    def display_context_status_notice(rdv_context)
      if @structure.present? && rdv_context.invited_before_time_window?(number_of_days_before_action_required) &&
         rdv_context.invitation_pending?
        " (Délai dépassé)"
      else
        ""
      end
    end

    def number_of_days_before_action_required
      @number_of_days_before_action_required ||= @structure.configurations.find do |c|
        c.motif_category == @motif_category
      end.number_of_days_before_action_required
    end

    def display_date(date)
      date&.strftime("%d/%m/%Y")
    end

    def display_time(datetime)
      datetime&.strftime("%kh%M")
    end

    def first_invitation_date(user)
      @motif_category.present? ? rdv_context(user)&.first_invitation_sent_at : user.first_invitation_sent_at
    end

    def last_invitation_date(user)
      @motif_category.present? ? rdv_context(user)&.last_invitation_sent_at : user.last_invitation_sent_at
    end

    def last_notification_date(user)
      return rdv_context(user)&.last_sent_convocation_sent_at if @motif_category.present?

      user.last_sent_convocation_sent_at
    end

    def last_rdv_date(user)
      @motif_category.present? ? rdv_context(user)&.last_rdv_starts_at : user.last_rdv_starts_at
    end

    def last_rdv(user)
      @motif_category.present? ? rdv_context(user)&.last_rdv : user.last_rdv
    end

    def last_participation(user)
      last_rdv(user).present? ? last_rdv(user).participation_for(user) : ""
    end

    def last_rdv_motif(user)
      last_rdv(user).present? ? last_rdv(user).motif.name : ""
    end

    def last_rdv_type(user)
      return "" if last_rdv(user).blank?

      last_rdv(user).collectif? ? "collectif" : "individuel"
    end

    def rdv_taken_in_autonomy?(user)
      return "" if last_participation(user).blank?

      I18n.t("boolean.#{last_participation(user).created_by_user?}")
    end

    def rdv_seen_in_less_than_30_days?(user)
      I18n.t("boolean.#{user.rdv_seen_delay_in_days.present? && user.rdv_seen_delay_in_days < 30}")
    end

    def rdv_context(user)
      user.rdv_context_for(@motif_category)
    end

    def department_level?
      @structure.instance_of?(Department)
    end

    def department_id
      department_level? ? @structure.id : @structure.department_id
    end
  end
end
# rubocop: enable Metrics/ClassLength
