require "csv"

class CreateApplicantsCsvExport < BaseService
  def initialize(applicants:, structure:, context:)
    @applicants = applicants
    @structure = structure
    @context = context
  end

  def call
    result.filename = filename
    result.csv = generate_csv
  end

  private

  def generate_csv
    csv = CSV.generate(write_headers: true, col_sep: ";", headers: headers, encoding: 'utf-8') do |row|
      @applicants.each do |applicant|
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
     "Dernière invitation envoyée le",
     "Date du dernier RDV",
     Applicant.human_attribute_name(:status),
     "Orienté ?",
     "Date d'orientation",
     "Archivé ?",
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
     format_date(applicant.birth_date),
     format_date(applicant.rights_opening_date),
     applicant.role,
     last_invitation_date(applicant),
     last_rdv_date(applicant),
     human_rdv_context_status(applicant),
     I18n.t("boolean.#{applicant.rdv_seen_in_30_days?}"),
     format_date(applicant.orientation_date),
     I18n.t("boolean.#{applicant.is_archived?}"),
     applicant.archiving_reason,
     applicant.department.number,
     applicant.department.name,
     applicant.organisations.to_a.count,
     applicant.organisations.collect(&:name).join(", ")]
  end

  def filename
    if @structure.nil?
      "Liste_beneficiaires.csv"
    else
      "Liste_beneficiaires_#{context_title}_#{@structure.class.model_name.human.downcase}_" \
        "#{@structure.name.parameterize(separator: '_')}.csv"
    end
  end

  def context_title
    @context.presence || "autres"
  end

  def human_rdv_context_status(applicant)
    return "Non invité" if rdv_context(applicant)&.status.nil?

    I18n.t("activerecord.attributes.rdv_context.statuses.#{rdv_context(applicant).status}")
  end

  def last_invitation_date(applicant)
    return "" if rdv_context(applicant)&.invitations.blank?

    format_date(rdv_context(applicant).last_invitation_sent_at)
  end

  def last_rdv_date(applicant)
    return "" unless rdv_context(applicant)

    format_date(rdv_context(applicant).rdvs.last&.starts_at)
  end

  def rdv_context(applicant)
    applicant.rdv_context_for(@context)
  end

  def format_date(date)
    date&.strftime("%d/%m/%Y")
  end
end
