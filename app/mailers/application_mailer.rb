class ApplicationMailer < ActionMailer::Base
  default from: 'RDV-Insertion <contact@rdv-insertion.fr>',
          reply_to: 'data.insertion@beta.gouv.fr'
  append_view_path Rails.root.join("app/views/mailers")
  layout "mailer"
end
