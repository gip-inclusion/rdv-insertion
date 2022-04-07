require 'csv'

# rails runner scripts/extract_applicants_to_csv.rb email organisation_id department_id
# email must be written as a string, ids as integers
# if csv wanted in console, precise nil for mail
# if extraction on department level wished, precise nil for organisation_id arg

EMAIL = ARGV[0] == "nil" ? nil : ARGV[0]
ORGANISATION_ID = ARGV[1] == "nil" ? nil : ARGV[1]
DEPARTMENT_ID = ARGV[2] == "nil" ? nil : ARGV[2]

structure = if DEPARTMENT_ID.present?
              Department.find(DEPARTMENT_ID)
            elsif ORGANISATION_ID.present?
              Organisation.find(ORGANISATION_ID)
            end

applicants = structure&.applicants || Applicant.order(:department_id)

headers = [Applicant.human_attribute_name(:title),
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

csv = CSV.generate(write_headers: true, col_sep: ";", headers: headers, encoding: 'utf-8') do |row|
  applicants.each do |applicant|
    row << [applicant.title,
            applicant.last_name,
            applicant.first_name,
            applicant.affiliation_number,
            applicant.department_internal_id,
            applicant.email,
            applicant.address,
            applicant.phone_number,
            applicant.birth_date&.strftime("%d/%m/%Y"),
            applicant.rights_opening_date&.strftime("%d/%m/%Y"),
            applicant.role,
            applicant.invitation_accepted_at&.strftime("%d/%m/%Y"),
            applicant.status,
            I18n.t("boolean.#{applicant.is_archived?}"),
            applicant.archiving_reason,
            applicant.department.number,
            applicant.department.name,
            applicant.organisations.count,
            applicant.organisations.collect(&:name).join(", "),
            applicant.last_invitation_sent_at&.strftime("%d/%m/%Y"),
            I18n.t("boolean.#{applicant.oriented?}"),
            applicant.orientation_date&.strftime("%d/%m/%Y"),
            applicant.rdvs.last&.starts_at&.strftime("%d/%m/%Y")]
  end
end

if EMAIL.present?
  CsvExportMailer.applicants_csv_export(csv, EMAIL, structure).deliver_now
else
  puts csv
end
