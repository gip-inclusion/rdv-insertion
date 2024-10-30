module AuthorizationConcern
  extend ActiveSupport::Concern

  include Pundit::Authorization

  included do
    rescue_from Pundit::NotAuthorizedError, with: :agent_not_authorized
  end

  private

  def pundit_user
    current_agent
  end

  def agent_not_authorized
    respond_to do |format|
      format.json { render_not_authorized }
      format.html { redirect_not_authorized }
      format.turbo_stream do
        turbo_stream_display_modal(partial: "errors/forbidden_modal", status: :forbidden)
      end
    end
  end

  def redirect_not_authorized
    flash[:alert] = "Votre compte ne vous permet pas d'effectuer cette action"
    redirect_to root_url, status: :see_other
  end

  def render_not_authorized
    render(
      status: :forbidden,
      json: {
        errors: ["Votre compte ne vous permet pas d'effectuer cette action"]
      }
    )
  end
end
