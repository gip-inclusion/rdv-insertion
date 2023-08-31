class ApplicationMailer < ActionMailer::Base
  default from: "rdv-insertion <contact@rdv-insertion.fr>"
  append_view_path Rails.root.join("app/views/mailers")
  layout "mailer"
end
