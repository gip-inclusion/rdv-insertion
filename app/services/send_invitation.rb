class SendInvitation < BaseService
  def initialize(invitation:)
    @invitation = invitation
  end

  def call
    case invitation_format
    when "sms"
      SendSmsInvitation.call(invitation: @invitation)
    when "email"
      # should add email service when implemented
    end
  end

  private

  def invitation_format
    @invitation.format
  end
end
