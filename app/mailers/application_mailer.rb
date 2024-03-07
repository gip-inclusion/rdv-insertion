class ApplicationMailer < ActionMailer::Base
  include Rails.application.routes.url_helpers

  default from: "rdv-insertion <support@rdv-insertion.fr>"
  append_view_path Rails.root.join("app/views/mailers")
  layout "mailer"
end
