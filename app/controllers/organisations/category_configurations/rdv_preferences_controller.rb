module Organisations
  module CategoryConfigurations
    class RdvPreferencesController < BaseController
      def show; end

      def edit; end

      def update
        if @category_configuration.update(rdv_preferences_params)
          render :update
        else
          turbo_stream_replace_error_list_with(@category_configuration.errors.full_messages)
        end
      end

      private

      def rdv_preferences_params
        params.expect(category_configuration: [{ invitation_formats: [] }, :convene_user, :rdv_with_referents,
                                               :phone_number])
      end
    end
  end
end
