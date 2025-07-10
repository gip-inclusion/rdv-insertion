class SuperAdminAuthenticationRequest < ApplicationRecord
  TOKEN_VERIFICATION_DURATION = 10.minutes.freeze
  TOKEN_VALIDITY_DURATION = 12.hours.freeze
  MAX_VERIFICATION_ATTEMPTS = 5

  belongs_to :agent

  validates :token, presence: true, format: { with: /\A[A-Z0-9]{6}\z/ }
  validate :must_belong_to_super_admin

  def verified?
    verified_at.present? && verified_at > TOKEN_VALIDITY_DURATION.ago && !invalidated?
  end

  def verify(token)
    increment_verification_attempts!
    validate_not_invalidated
    validate_not_expired
    validate_token(token)

    errors.empty? && update(verified_at: Time.current)
  end

  def invalidate!
    update!(invalidated_at: Time.current)
  end

  private

  def validate_not_invalidated
    errors.add(:base, :invalidated) if invalidated?
  end

  def validate_not_expired
    errors.add(:base, :expired) if expired?
  end

  def validate_token(token)
    errors.add(:base, :token_invalid) unless ActiveSupport::SecurityUtils.secure_compare(token, self.token)
  end

  def invalidated?
    invalidated_at.present?
  end

  def expired?
    created_at < TOKEN_VERIFICATION_DURATION.ago
  end

  def increment_verification_attempts!
    self.verification_attempts += 1
    self.invalidated_at ||= Time.current if too_many_attempts?
    save!
  end

  def too_many_attempts?
    verification_attempts >= MAX_VERIFICATION_ATTEMPTS
  end

  def must_belong_to_super_admin
    errors.add(:base, :not_super_admin) unless agent.super_admin?
  end
end
