class ApplicationMailer < ActionMailer::Base
  default from: "rdv-insertion <support@rdv-insertion.fr>"
  append_view_path Rails.root.join("app/views/mailers")
  layout "mailer"

  before_action :set_active_storage_current, unless: Rails.env.production?

  def set_active_storage_current
    ActiveStorage::Current.url_options = { host: "localhost", port: 8000 }
  end
end
