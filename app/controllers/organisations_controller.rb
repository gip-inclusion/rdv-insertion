class OrganisationsController < ApplicationController
  def index
    @organisations = policy_scope(Organisation)
    redirect_to organisation_applicants_path(@organisations.first) if @organisations.size == 1
  end
end
