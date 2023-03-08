class StaticPagesController < ApplicationController
  skip_before_action :authenticate_agent!

  def welcome
    redirect_to(organisations_path) if logged_in?
  end

  def legal_notice; end

  def cgu; end

  def privacy_policy; end

  def accessibility; end
end
