module SuperAdmins
  module RedirectAndRenderConcern
    # the methods below are extracted from the default actions in Administrate::ApplicationController
    # they are redefined here to allow an easier customization of the actions
    def redirect_after_successful_create
      redirect_to(
        after_resource_created_path(resource),
        notice: translate_with_resource("create.success")
      )
    end

    def redirect_after_successful_update
      redirect_to(
        after_resource_updated_path(requested_resource),
        notice: translate_with_resource("update.success")
      )
    end

    def render_new
      render :new, locals: {
        page: Administrate::Page::Form.new(dashboard, resource)
      }, status: :unprocessable_entity
    end

    def render_edit
      render :edit, locals: {
        page: Administrate::Page::Form.new(dashboard, requested_resource)
      }, status: :unprocessable_entity
    end
  end
end
