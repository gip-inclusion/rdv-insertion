module InboundWebhooks
  module RdvSolidarites
    class ProcessUserJob < ApplicationJob
      def perform(data, meta)
        @data = data.deep_symbolize_keys
        @meta = meta.deep_symbolize_keys
        return if user.blank?

        remove_attributes_from_payload
        upsert_or_delete_user
      end

      private

      def event
        @meta[:event]
      end

      def rdv_solidarites_user_id
        @data[:id]
      end

      def affiliation_number
        @data[:affiliation_number]
      end

      def email
        @data[:email] || @data[:notification_email]
      end

      def user
        @user ||= User.find_by(rdv_solidarites_user_id: rdv_solidarites_user_id)
      end

      def remove_attributes_from_payload
        # if the affiliation number is nil in RDV-S following a user fusion, we cannot update to nil
        # in RDV-I because we need it to keep it for the uid.
        @data.delete(:affiliation_number) if affiliation_number.blank?

        # If a user is created without email in RDV-S, for the conjoint for example, we do not
        # want the email to be nil in RDV-I or we cannot invite by email
        @data.delete(:email) if email.blank?

        # We store the user's email in email field whether it is the devise account email or the notification email
        @data[:email] = email if email.present?
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
