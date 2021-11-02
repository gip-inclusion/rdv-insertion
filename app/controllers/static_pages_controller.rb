class StaticPagesController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:home, :welcome]

  def welcome; end

  def home
    if logged_in?
      redirect_to(departments_path)
    else
      redirect_to(root_path)
    end
  end
end
