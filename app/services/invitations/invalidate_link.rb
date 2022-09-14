module Invitations
  class InvalidateLink < BaseService
    def initialize(invitation:)
      @invitation = invitation
    end

    def call
      @invitation.valid_until = Time.zone.now
      save_record!(@invitation)
      result.invitation = @invitation
    end
  end
end
