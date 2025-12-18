module Organisations
  module Configuration
    class MessagesController < BaseController
      def show
        @messages_configuration = @organisation.messages_configuration
        @category_configurations = @organisation.category_configurations.includes([:motif_category])
      end
    end
  end
end
