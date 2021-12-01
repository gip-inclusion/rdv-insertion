class StaticPagesController < ApplicationController
  skip_before_action :authenticate_agent!, only: [:welcome]

  def welcome
    redirect_to(organisations_path) if logged_in?

    @rdvs = Rdv.all
    @applicants = Applicant.all
    @invitations = Invitation.all
    @agents = Agent.all
    @organisations = Organisation.all

    @stats = Stat.new(applicants: @applicants, agents: @agents, invitations: @invitations,
                      organisations: @organisations, rdvs: @rdvs)
  end
end
