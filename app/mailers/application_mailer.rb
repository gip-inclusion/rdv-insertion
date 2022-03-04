class ApplicationMailer < ActionMailer::Base
  default from: 'RDV-Insertion <contact@rdv-insertion.fr>'
  append_view_path Rails.root.join("app/views/mailers")
  layout "mailer"
end
