module Organisations
  module CategoryConfigurations
    class InvitationSettingsController < BaseController
      def show; end

      def edit; end

      def update
        if @category_configuration.update(invitation_settings_params)
          render :update
        else
          turbo_stream_replace_error_list_with(@category_configuration.errors.full_messages)
        end
      end

      private

      def invitation_settings_params
        params.expect(category_configuration: [:invite_to_user_organisations_only,
                                               :number_of_days_before_invitations_expire])
      end
    end
  end
end
