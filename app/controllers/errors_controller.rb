class ErrorsController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:not_found, :unprocessable_entity, :internal_server_error]

  def not_found
    render :'404'
  end

  def unprocessable_entity
    render :'422'
  end

  def internal_server_error
    render :'500'
  end
end
