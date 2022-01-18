class StaticPagesController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:welcome, :legal_notice, :privacy_policy, :accessibility, :error]

  def welcome
    redirect_to(organisations_path) if logged_in?

    @applicants = Applicant.all
    @agents = Agent.all
    @invitations = Invitation.all
    @rdvs = Rdv.all
    @organisations = Organisation.all

    @stats = Stat.new(applicants: @applicants, agents: @agents, invitations: @invitations,
                      rdvs: @rdvs, organisations: @organisations)
  end

  def legal_notice; end

  def privacy_policy; end

  def accessibility; end

  def error
    status = params[:code].present? ? params[:code].to_s : "500"
    render status
  end
end
