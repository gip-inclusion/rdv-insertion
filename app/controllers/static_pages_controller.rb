class StaticPagesController < ApplicationController
  skip_before_action :authenticate_agent!

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
end
