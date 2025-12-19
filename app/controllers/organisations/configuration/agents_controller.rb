module Organisations
  module Configuration
    class AgentsController < BaseController
      def show
        @agent_roles = @organisation.agent_roles
      end
    end
  end
end
