module Agent::SuperAdminAuthentication
  extend ActiveSupport::Concern

  included do
    has_many :super_admin_authentication_requests, dependent: :destroy
  end

  def generate_and_send_super_admin_authentication_request!
    token = SecureRandom.alphanumeric(6).upcase
    super_admin_authentication_requests.create!(token: token)
    SuperAdminMailer.send_authentication_token(self, token).deliver_now!
  end

  def super_admin_token_verified_and_valid?
    super_admin? && last_super_admin_authentication_request&.verified_and_valid?
  end

  def invalidate_super_admin_authentication_request!
    last_super_admin_authentication_request&.invalidate!
  end

  def last_super_admin_authentication_request
    super_admin_authentication_requests.order(created_at: :desc).first
  end
end
