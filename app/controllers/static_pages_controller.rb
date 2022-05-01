class StaticPagesController < ApplicationController
  skip_before_action :authenticate_agent!

  include StatsConcern

  def welcome
    redirect_to(organisations_path) if logged_in?

    collect_datas_for_stats
    set_stats_datas
  end

  def legal_notice; end

  def privacy_policy; end

  def accessibility; end
end
