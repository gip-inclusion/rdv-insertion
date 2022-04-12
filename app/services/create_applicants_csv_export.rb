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
    CSV.generate(write_headers: true, col_sep: ";", headers: headers, encoding: 'utf-8') do |row|
      @applicants.each do |applicant|
        row << applicant_csv(applicant)
      end
    end
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
     "Invitation acceptée le",
     Applicant.human_attribute_name(:status),
     "Archivé ?",
     Applicant.human_attribute_name(:archiving_reason),
     "Numéro du département",
     "Nom du département",
     "Nombre d'organisations",
     "Nom des organisations",
     "Dernière invitation envoyée le",
     "Orienté ?",
     "Date d'orientation",
     "Date du rendez-vous le plus récent"]
  end

  def applicant_csv(applicant) # rubocop:disable Metrics/AbcSize
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
     format_date(applicant.invitation_accepted_at),
     rdv_context_status(applicant),
     I18n.t("boolean.#{applicant.is_archived?}"),
     applicant.archiving_reason,
     applicant.department.number,
     applicant.department.name,
     applicant.organisations.count,
     applicant.organisations.collect(&:name).join(", "),
     format_date(applicant.last_invitation_sent_at),
     I18n.t("boolean.#{applicant.oriented?}"),
     format_date(applicant.orientation_date),
     rdv_context_date(applicant)]
  end

  def filename
    if @structure.nil?
      "applicants_extraction.csv"
    else
      "#{@structure.class.name}_#{@structure.name.parameterize(separator: '_')}_applicants_extraction.csv"
    end
  end

  def rdv_context_status(applicant)
    rdv_context(applicant)&.status || "Non invité"
  end

  def rdv_context_date(applicant)
    rdv_context(applicant) ? format_date(rdv_context(applicant).rdvs.last&.starts_at) : ""
  end

  def rdv_context(applicant)
    applicant.rdv_contexts.find_by(context: @context)
  end

  def format_date(date)
    date&.strftime("%d/%m/%Y")
  end
end
