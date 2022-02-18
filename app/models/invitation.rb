class Invitation < ApplicationRecord
  belongs_to :applicant
  belongs_to :department
  has_and_belongs_to_many :organisations

  validates :help_phone_number, :context, :token, :organisations, :link, presence: true
  validate :organisations_cannot_be_from_different_departments

  enum format: { sms: 0, email: 1, postal: 2 }, _prefix: :format
  after_commit :set_applicant_status

  scope :sent_in_time_window, -> { where("sent_at > ?", Organisation::TIME_TO_ACCEPT_INVITATION.ago) }

  def send_to_applicant
    case self.format
    when "sms"
      Invitations::SendSms.call(invitation: self)
    when "email"
      Invitations::SendEmail.call(invitation: self)
    when "postal"
      Invitations::GenerateLetter.call(invitation: self)
    end
  end

  private

  def organisations_cannot_be_from_different_departments
    return if organisations.map(&:department_id).uniq == [department_id]

    errors.add(:organisations, :invalid)
  end

  def set_applicant_status
    RefreshApplicantStatusesJob.perform_async(applicant.id)
  end
end
