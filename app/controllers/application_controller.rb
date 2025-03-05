class ApplicationController < ActionController::Base
  include AuthenticatedControllerConcern
  include AuthorizationConcern
  include CurrentStructure
  include NavigationHelper
  include PolicyHelper
  include BeforeActionOverride
  include TurboStreamConcern
  include ModalAgreementsConcern
  include CrispConcern

  protect_from_forgery with: :exception
  before_action :set_sentry_context

  # Needed to generate ActiveStorage urls locally, it sets the host and protocol
  include ActiveStorage::SetCurrent unless Rails.env.production?

  private

  def set_sentry_context
    Sentry.set_user(sentry_user)
  end

  def sentry_user
    {
      id: current_agent&.id,
      email: current_agent&.email
    }.compact
  end

  def page
    params[:page] || 1
  end

  def current_url_is_root_url?
    request.path.in?([root_path, authenticated_root_path])
  end

  # A user can be unlinked from its rdv-solidarites record when the latter is deleted for RGPD reasons.
  # This method pushes the user to rdv-solidarites to recreate a new one.
  def recreate_rdv_solidarites_user(user)
    push = Users::PushToRdvSolidarites.call(user: user)
    return if push.success?

    respond_to do |format|
      format.turbo_stream do
        flash.now[:error] = "L'usager n'est plus lié à rdv-solidarités: #{push.errors.map(&:to_s)}"
      end
      format.json { render json: { errors: push.errors.map(&:to_s) }, status: :unprocessable_entity }
    end
  end
end
