require "csv"

# rubocop:disable Metrics/ClassLength
module Exporters
  class GenerateApplicantsCsv < BaseService
    def initialize(applicants:, structure: nil, motif_category: nil)
      @applicants = applicants
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
        @applicants.preload(:organisations, :rdvs, rdv_contexts: [:invitations]).each do |applicant|
          row << applicant_csv_row(applicant)
        end
      end
      # We add a BOM at the beginning of the file to enable a correct parsing of accented characters in Excel
      "\uFEFF#{csv}"
    end

    def headers
      [Applicant.human_attribute_name(:title),
       Applicant.human_attribute_name(:last_name),
       Applicant.human_attribute_name(:first_name),
       Applicant.human_attribute_name(:affiliation_number),
       Applicant.human_attribute_name(:department_internal_id),
       Applicant.human_attribute_name(:nir),
       Applicant.human_attribute_name(:pole_emploi_id),
       Applicant.human_attribute_name(:email),
       Applicant.human_attribute_name(:address),
       Applicant.human_attribute_name(:phone_number),
       Applicant.human_attribute_name(:birth_date),
       Applicant.human_attribute_name(:created_at),
       Applicant.human_attribute_name(:rights_opening_date),
       Applicant.human_attribute_name(:role),
       "Première invitation envoyée le",
       "Dernière invitation envoyée le",
       "Date du dernier RDV",
       "Dernier RDV pris en autonomie ?",
       Applicant.human_attribute_name(:status),
       "1er RDV honoré en - de 30 jours ?",
       "Date d'orientation",
       Archive.human_attribute_name(:created_at),
       Archive.human_attribute_name(:archiving_reason),
       Applicant.human_attribute_name(:referents),
       "Nombre d'organisations",
       "Nom des organisations"]
    end

    def applicant_csv_row(applicant) # rubocop:disable Metrics/AbcSize
      [applicant.title,
       applicant.last_name,
       applicant.first_name,
       applicant.affiliation_number,
       applicant.department_internal_id,
       applicant.nir,
       applicant.pole_emploi_id,
       applicant.email,
       applicant.address,
       applicant.phone_number,
       display_date(applicant.birth_date),
       display_date(applicant.created_at),
       display_date(applicant.rights_opening_date),
       applicant.role,
       display_date(first_invitation_date(applicant)),
       display_date(last_invitation_date(applicant)),
       display_date(last_rdv_date(applicant)),
       rdv_taken_in_autonomy?(applicant),
       human_rdv_context_status(applicant),
       rdv_seen_in_less_than_30_days?(applicant),
       display_date(applicant.first_seen_rdv_starts_at),
       display_date(applicant.archive_for(department_id)&.created_at),
       applicant.archive_for(department_id)&.archiving_reason,
       applicant.referents.map(&:email).join(", "),
       applicant.organisations.to_a.count,
       applicant.organisations.map(&:name).join(", ")]
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

    def human_rdv_context_status(applicant)
      return "Archivé" if applicant.archive_for(department_id).present?

      return "" if @motif_category.nil? || rdv_context(applicant).nil?

      I18n.t("activerecord.attributes.rdv_context.statuses.#{rdv_context(applicant).status}") +
        display_context_status_notice(rdv_context(applicant))
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
      return "" if date.blank?

      format_date(date)
    end

    def first_invitation_date(applicant)
      @motif_category.present? ? rdv_context(applicant)&.first_invitation_sent_at : applicant.first_invitation_sent_at
    end

    def last_invitation_date(applicant)
      @motif_category.present? ? rdv_context(applicant)&.last_invitation_sent_at : applicant.last_invitation_sent_at
    end

    def last_rdv_date(applicant)
      @motif_category.present? ? rdv_context(applicant)&.last_rdv_starts_at : applicant.last_rdv_starts_at
    end

    def last_rdv(applicant)
      @motif_category.present? ? rdv_context(applicant)&.last_rdv : applicant.last_rdv
    end

    def rdv_taken_in_autonomy?(applicant)
      return "" if last_rdv(applicant).blank?

      I18n.t("boolean.#{last_rdv(applicant).created_by_user?}")
    end

    def rdv_seen_in_less_than_30_days?(applicant)
      I18n.t("boolean.#{applicant.rdv_seen_delay_in_days.present? && applicant.rdv_seen_delay_in_days < 30}")
    end

    def rdv_context(applicant)
      applicant.rdv_context_for(@motif_category)
    end

    def department_level?
      @structure.instance_of?(Department)
    end

    def department_id
      department_level? ? @structure.id : @structure.department_id
    end

    def format_date(date)
      date&.strftime("%d/%m/%Y")
    end
  end
end
# rubocop: enable Metrics/ClassLength
