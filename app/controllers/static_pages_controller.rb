class StaticPagesController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:welcome]

  def welcome
    redirect_to(organisations_path) if logged_in?
  end
end
