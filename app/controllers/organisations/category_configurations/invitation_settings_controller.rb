module Organisations
  module CategoryConfigurations
    class InvitationSettingsController < BaseController
      def show; end

      def edit; end

      def update
        @category_configuration.assign_attributes(invitation_settings_params)
        if @category_configuration.save
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
