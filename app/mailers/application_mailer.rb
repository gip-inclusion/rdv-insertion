class ApplicationMailer < ActionMailer::Base
  default from: "rdv-insertion <support@rdv-insertion.fr>"
  append_view_path Rails.root.join("app/views/mailers")
  layout "mailer"

  include ActiveStorageCurrent if Rails.env.development?
end
