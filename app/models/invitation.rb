class Invitation < ApplicationRecord
  belongs_to :applicant
  belongs_to :department
  belongs_to :rdv_context
  has_and_belongs_to_many :organisations

  attr_accessor :content

  validates :help_phone_number, :context, :token, :organisations, :link, presence: true
  validate :organisations_cannot_be_from_different_departments

  delegate :context, :context_name, to: :rdv_context

  enum format: { sms: 0, email: 1, postal: 2 }, _prefix: :format
  after_commit :set_applicant_status, :set_rdv_context_status

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

  def help_phone_number_formatted
    Phonelib.parse(help_phone_number).national
  end

  def as_json(_opts = {})
    super.merge(
      context: context
    )
  end

  private

  def organisations_cannot_be_from_different_departments
    return if organisations.map(&:department_id).uniq == [department_id]

    errors.add(:organisations, :invalid)
  end

  def set_applicant_status
    RefreshApplicantStatusesJob.perform_async(applicant.id)
  end

  def set_rdv_context_status
    RefreshRdvContextStatusesJob.perform_async(rdv_context_id)
  end
end
