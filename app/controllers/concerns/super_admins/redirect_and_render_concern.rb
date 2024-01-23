module SuperAdmins
  module RedirectAndRenderConcern
    # the methods below are extracted from the default actions in Administrate::ApplicationController
    # they are redefined here to allow an easier customization of the actions
    def redirect_after_succesful_action(action_name)
      redirect_to(
        send("after_resource_#{action_name}d_path", resource),
        notice: translate_with_resource("#{action_name}.success")
      )
    end

    def render_page(page, record, errors)
      flash[:error] = errors.join("<br/>")
      render page, locals: {
        page: Administrate::Page::Form.new(dashboard, record)
      }, status: :unprocessable_entity
    end
  end
end
