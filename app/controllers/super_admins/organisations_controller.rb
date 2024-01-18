module SuperAdmins
  class OrganisationsController < SuperAdmins::ApplicationController
    # Overwrite any of the RESTful controller actions to implement custom behavior
    # For example, you may want to send an email after a foo is updated.
    #

    def create
      create_organisation.success? ? redirect_after_successful_create : render_new
    end

    def update
      requested_resource.assign_attributes(**resource_params)
      update_organisation.success? ? redirect_after_successful_update : render_edit
    end

    private

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
