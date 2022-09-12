module Invitations
  class InvalidateToken < BaseService
    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      @invitation.valid_until = DateTime.now
      save_record!(@invitation)
      result.invitation = @invitation
    end
  end
end
