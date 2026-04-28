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

        upsert_or_delete_user
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

      def upsert_or_delete_user
        if event == "destroyed"
          SoftDeleteUserJob.perform_later(rdv_solidarites_user_id)
        else
          UpsertRecordJob.perform_later("User", @data, { last_webhook_update_received_at: @meta[:timestamp] })
        end
      end
    end
  end
end
