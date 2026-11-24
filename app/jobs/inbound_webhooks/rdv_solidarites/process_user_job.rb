module InboundWebhooks
  module RdvSolidarites
    class ProcessUserJob < LockedAndOrderedJobBase
      def self.lock_key(data, _meta)
        "#{base_lock_key}:#{data[:id]}"
      end

      def perform(data, meta)
        @data = data.deep_symbolize_keys
        @meta = meta.deep_symbolize_keys
        return if user.blank?

        update_or_delete_user
      end

      private

      def event
        @meta[:event]
      end

      def rdv_solidarites_user_id
        @data[:id]
      end

      def user
        @user ||= User.find_by(rdv_solidarites_user_id: rdv_solidarites_user_id)
      end

      def update_or_delete_user
        if event == "destroyed"
          SoftDeleteUserJob.perform_later(rdv_solidarites_user_id)
        else
          update_user
        end
      end

      def update_user
        call_service!(
          UpsertRecord,
          klass: User,
          rdv_solidarites_attributes: @data,
          additional_attributes: { last_webhook_update_received_at: @meta[:timestamp] }
        )
      end
    end
  end
end
