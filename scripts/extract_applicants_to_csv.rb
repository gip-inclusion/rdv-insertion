require 'csv'

# rails runner scripts/extract_applicants_to_csv.rb email organisation_id department_id
# email must be written as a string, ids as integers
# if csv wanted in console, precise nil for mail
# if extraction on department level wished, precise nil for organisation_id arg

EMAIL = ARGV[0] == "nil" ? nil : ARGV[0]
ORGANISATION_ID = ARGV[1] == "nil" ? nil : ARGV[1]
DEPARTMENT_ID = ARGV[2] == "nil" ? nil : ARGV[2]
MOTIF_CATEGORY = ARGV[3] == "nil" ? nil : ARGV[3]

structure = if DEPARTMENT_ID.present?
              Department.find(DEPARTMENT_ID)
            elsif ORGANISATION_ID.present?
              Organisation.find(ORGANISATION_ID)
            end

applicants = structure&.applicants || Applicant.order(:department_id)
context_applicants = if CONTEXT.present?
                       applicants.joins(:rdv_contexts).where(rdv_contexts: { motif_category: MOTIF_CATEGORY })
                     else
                       applicants.where.missing(:rdv_contexts)
                     end

result = Applicants::GenerateApplicantsCsv.call(
  applicants: context_applicants, structure: structure, motif_category: MOTIF_CATEGORY
)

if EMAIL.present?
  CsvExportMailer.applicants_csv_export(EMAIL, result.csv, result.filename).deliver_now
else
  puts result.csv
end
