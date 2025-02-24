# rubocop:disable Rails/LexicallyScopedActionFilter
module SuperAdmins
  class OrganisationsController < SuperAdmins::ApplicationController
    before_action :set_starts_at, :set_ends_at, :set_blocked_invitations_counters_grouped_by_day, only: :show

    def create
      if create_organisation.success?
        redirect_after_succesful_action(resource)
      else
        render_page(:new, resource, create_organisation.errors)
      end
    end

    def update
      requested_resource.assign_attributes(**resource_params)
      if update_organisation.success?
        redirect_after_succesful_action(requested_resource)
      else
        render_page(:edit, requested_resource, update_organisation.errors)
      end
    end

    private

    def scoped_resource
      resource_class.with_attached_logo
    end

    def resource
      @resource ||= Organisation.new(resource_params)
    end

    def create_organisation
      @create_organisation ||= Organisations::Create.call(organisation: resource)
    end

    def update_organisation
      @update_organisation ||= Organisations::Update.call(organisation: requested_resource)
    end

    def default_sorting_attribute
      :department
    end

    def set_starts_at
      @starts_at = params[:starts_at] || 30.days.ago
    end

    def set_ends_at
      @ends_at = params[:ends_at] || Time.zone.now
    end

    def set_blocked_invitations_counters_grouped_by_day
      @blocked_invitations_counters_grouped_by_day = BlockedInvitationsCounter.where(organisation: requested_resource)
                                                                              .grouped_by_day(@starts_at, @ends_at)
    end

    # Override this method to specify custom lookup behavior.
    # This will be used to set the resource for the `show`, `edit`, and `update`
    # actions.
    #
    # def find_resource(param)
    #   Foo.find_by!(slug: param)
    # end

    # The result of this lookup will be available as `requested_resource`

    # Override this if you have certain roles that require a subset
    # this will be used to set the records shown on the `index` action.
    #
    # def scoped_resource
    #   if current_user.super_admin?
    #     resource_class
    #   else
    #     resource_class.with_less_stuff
    #   end
    # end

    # Override `resource_params` if you want to transform the submitted
    # data before it's persisted. For example, the following would turn all
    # empty values into nil values. It uses other APIs such as `resource_class`
    # and `dashboard`:
    #
    # def resource_params
    #   params.require(resource_class.model_name.param_key).
    #     permit(dashboard.permitted_attributes).
    #     transform_values { |value| value == "" ? nil : value }
    # end
  end
end
# rubocop:enable Rails/LexicallyScopedActionFilter
