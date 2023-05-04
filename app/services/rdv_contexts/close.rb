module RdvContexts
  class Close < BaseService
    def initialize(rdv_context:)
      @rdv_context = rdv_context
    end

    def call
      RdvContext.transaction do
        @rdv_context.status = "closed"
        @rdv_context.closed_at = Time.zone.now
        save_record!(@rdv_context)
        @rdv_context.invalidate_invitations
      end
    end
  end
end
