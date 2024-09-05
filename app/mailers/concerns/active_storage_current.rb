module ActiveStorageCurrent
  extend ActiveSupport::Concern

  included do
    before_action :set_active_storage_current
  end

  private

  def set_active_storage_current
    ActiveStorage::Current.url_options = { host: ENV["HOST"] }
  end
end
