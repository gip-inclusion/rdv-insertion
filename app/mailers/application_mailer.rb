class ApplicationMailer < ActionMailer::Base
  include Rails.application.routes.url_helpers

  # Needed to generate ActiveStorage urls locally and for the tests
  before_action :set_active_storage_url_options unless Rails.env.production?

  default from: "rdv-insertion <support@rdv-insertion.fr>"
  append_view_path Rails.root.join("app/views/mailers")
  layout "mailer"

  private

  def set_active_storage_url_options
    ActiveStorage::Current.url_options = ActionMailer::Base.default_url_options
  end
end
