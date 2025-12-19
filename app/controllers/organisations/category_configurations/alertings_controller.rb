module Organisations
  module CategoryConfigurations
    class AlertingsController < BaseController
      def show; end

      def edit; end

      def update
        if @category_configuration.update(alertings_params)
          render :update
        else
          turbo_stream_replace_error_list_with(@category_configuration.errors.full_messages)
        end
      end

      private

      def alertings_params
        params.expect(category_configuration: [:email_to_notify_rdv_changes, :email_to_notify_no_available_slots])
      end
    end
  end
end
