require "csv"

# rubocop:disable Metrics/ClassLength

module Applicants
  class GenerateApplicantsCsv < BaseService
    def initialize(applicants:, structure:, motif_category:)
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
      csv = CSV.generate(write_headers: true, col_sep: ";", headers: headers, encoding: 'utf-8') do |row|
        @applicants
          .includes(:department).preload(:organisations, :rdvs, rdv_contexts: [:invitations])
          .each do |applicant|
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
       Applicant.human_attribute_name(:email),
       Applicant.human_attribute_name(:address),
       Applicant.human_attribute_name(:phone_number),
       Applicant.human_attribute_name(:birth_date),
       Applicant.human_attribute_name(:rights_opening_date),
       Applicant.human_attribute_name(:role),
       "Première invitation envoyée le",
       "Dernière invitation envoyée le",
       "Date du dernier RDV",
       "Dernier RDV pris en autonomie ?",
       Applicant.human_attribute_name(:status),
       "RDV honoré en - de 30 jours ?",
       "Date d'orientation",
       Applicant.human_attribute_name(:archived_at),
       Applicant.human_attribute_name(:archiving_reason),
       "Numéro du département",
       "Nom du département",
       "Nombre d'organisations",
       "Nom des organisations"]
    end

    def applicant_csv_row(applicant) # rubocop:disable Metrics/AbcSize
      [applicant.title,
       applicant.last_name,
       applicant.first_name,
       applicant.affiliation_number,
       applicant.department_internal_id,
       applicant.email,
       applicant.address,
       applicant.phone_number,
       display_date(applicant.birth_date),
       display_date(applicant.rights_opening_date),
       applicant.role,
       display_date(first_invitation_date(applicant)),
       display_date(last_invitation_date(applicant)),
       display_date(last_rdv_date(applicant)),
       rdv_taken_in_autonomy?(applicant),
       human_rdv_context_status(applicant),
       I18n.t("boolean.#{applicant.first_seen_rdv_starts_at.present?}"),
       display_date(applicant.first_seen_rdv_starts_at),
       display_date(applicant.archived_at),
       applicant.archiving_reason,
       applicant.department.number,
       applicant.department.name,
       applicant.organisations.to_a.count,
       applicant.organisations.map(&:name).join(", ")]
    end

    def filename
      "Liste_beneficiaires_#{motif_category_title}_#{@structure.class.model_name.human.downcase}_" \
        "#{@structure.name.parameterize(separator: '_')}.csv"
    end

    def motif_category_title
      @motif_category.presence || "autres"
    end

    def human_rdv_context_status(applicant)
      return "" if rdv_context(applicant).nil?

      I18n.t("activerecord.attributes.rdv_context.statuses.#{rdv_context(applicant).status}") +
        display_context_status_notice(rdv_context(applicant), number_of_days_before_action_required)
    end

    def number_of_days_before_action_required
      @number_of_days_before_action_required ||= @structure.configurations.find do |c|
        c.motif_category == @motif_category
      end.number_of_days_before_action_required
    end

    def display_context_status_notice(rdv_context, number_of_days_before_action_required)
      if rdv_context.invited_before_time_window?(number_of_days_before_action_required) && rdv_context.invitation_pending?
        " (Délai dépassé)"
      else
        ""
      end
    end

    def display_date(date)
      return "" if date.blank?

      format_date(date)
    end

    def first_invitation_date(applicant)
      rdv_context(applicant)&.first_invitation_sent_at
    end

    def last_invitation_date(applicant)
      rdv_context(applicant)&.last_invitation_sent_at
    end

    def last_rdv_date(applicant)
      rdv_context(applicant)&.last_rdv_starts_at
    end

    def last_rdv(applicant)
      rdv_context(applicant)&.last_rdv
    end

    def rdv_taken_in_autonomy?(applicant)
      return "" unless rdv_context(applicant) && last_rdv(applicant).present?

      I18n.t("boolean.#{last_rdv(applicant).created_by_user?}")
    end

    def rdv_context(applicant)
      applicant.rdv_context_for(@motif_category)
    end

    def format_date(date)
      date&.strftime("%d/%m/%Y")
    end
  end

  # rubocop: enable Metrics/ClassLength
end
