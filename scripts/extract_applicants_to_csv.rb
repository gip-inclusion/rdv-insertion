require 'csv'

# rails runner scripts/extract_applicants_to_csv.rb email organisation_id department_id
# email must be written as a string, ids as integers
# if extraction on department level wished, precise nil for organisation_id arg

EMAIL = ARGV[0]
ORGANISATION_ID = ARGV[1]
DEPARTMENT_ID = ARGV[2]

applicants = if DEPARTMENT_ID.present?
               Applicant.where(department_id: DEPARTMENT_ID)
             elsif ORGANISATION_ID.present?
               Applicant.where(organisation_id: ORGANISATION_ID)
             else
               Applicant.order(:department_id)
             end

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
            applicant.birth_date,
            applicant.rights_opening_date,
            applicant.role,
            applicant.invitation_accepted_at,
            applicant.status,
            applicant.is_archived,
            applicant.archiving_reason,
            Department.find(applicant.department_id).number,
            applicant.last_invitation_sent_at,
            applicant.oriented?,
            applicant.orientation_date,
            applicant.rdvs.last&.starts_at]
  end
end

ExtractionMailer.extract_applicants_with_script(EMAIL, csv).deliver_now
