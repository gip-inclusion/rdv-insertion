class ErrorsController < ApplicationController
  before_action :set_not_found_error_message, only: [:not_found]
  before_action :set_unprocessable_entity_error_message, only: [:unprocessable_entity]
  before_action :set_internal_server_error_message, only: [:internal_server_error]

  skip_before_action :authenticate_agent!, only: [:not_found, :unprocessable_entity, :internal_server_error]

  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.turbo_stream { render status: :not_found }
      format.json { render json: { success: false, errors: [@not_found_error_message] }, status: :not_found }
    end
  end

  def unprocessable_entity
    respond_to do |format|
      format.html { render status: :unprocessable_entity }
      format.turbo_stream { render status: :unprocessable_entity }
      format.json do
        render json: { success: false, errors: [@unprocessable_entity_error_message] }, status: :unprocessable_entity
      end
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render status: :internal_server_error }
      format.turbo_stream { render status: :internal_server_error }
      format.json do
        render json: { success: false, errors: [@internal_server_error_message] }, status: :internal_server_error
      end
    end
  end

  private

  def set_not_found_error_message
    model_name = request.env["action_dispatch.exception"].model \
      if request.env["action_dispatch.exception"].respond_to?(:model)

    @not_found_error_message = "🔎 Erreur 404 - #{model_name.presence || 'La ressource'} est introuvable"
  end

  def set_unprocessable_entity_error_message
    @unprocessable_entity_error_message =
      "Erreur 422 - Une erreur s'est produite," \
      " nous nous efforçons de résoudre le problème le plus vite possible"
  end

  def set_internal_server_error_message
    @internal_server_error_message =
      "Erreur 500 - Une erreur s'est produite," \
      " nous nous efforçons de résoudre le problème le plus vite possible"
  end
end
