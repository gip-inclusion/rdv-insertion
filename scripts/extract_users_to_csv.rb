require "csv"

# rails runner scripts/extract_users_to_csv.rb email organisation_id department_id
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

users = structure&.users || User.order(:department_id)
context_users = if CONTEXT.present?
                  users.joins(:rdv_contexts).where(rdv_contexts: { motif_category: MOTIF_CATEGORY })
                else
                  users.where.missing(:rdv_contexts)
                end

result = Exports::GenerateUsersCsv.call(
  users: context_users, structure: structure, motif_category: MOTIF_CATEGORY
)

if EMAIL.present?
  CsvExportMailer.internal_users_csv_export(EMAIL, result.csv, result.filename).deliver_now
else
  puts result.csv
end
