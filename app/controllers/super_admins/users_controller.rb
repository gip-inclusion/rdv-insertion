module SuperAdmins
  class UsersController < SuperAdmins::ApplicationController
    # Overwrite any of the RESTful controller actions to implement custom behavior
    # For example, you may want to send an email after a foo is updated.
    #
    def index
      page = Administrate::Page::Collection.new(dashboard, order:)
      resources = order.apply(scoped_resource).page(params[:page]).per(records_per_page)

      render locals: { resources:, search_term: params[:search], page:, show_search_bar: true, filters: [] }
    end

    def update
      requested_resource.assign_attributes(**resource_params)
      if save_user.success?
        redirect_after_succesful_action(requested_resource)
      else
        render_page(:edit, requested_resource, save_user.errors)
      end
    end

    private

    def save_user
      @save_user ||= Users::Save.call(user: requested_resource)
    end

    def default_sorting_attribute
      :last_name
    end

    def scoped_resource
      return User.active if params[:search].blank?

      User.active.search_by_text(params[:search])
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
    # data before it's persisted.
  end
end
