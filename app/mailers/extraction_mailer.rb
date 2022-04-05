class ExtractionMailer < ApplicationMailer
  def extract_applicants_with_script(csv, email)
    attachments["applicants_extraction.csv"] = { mime_type: 'text/csv', content: csv }
    mail(
      to: email,
      subject: "",
      body: ""
    )
  end
end
