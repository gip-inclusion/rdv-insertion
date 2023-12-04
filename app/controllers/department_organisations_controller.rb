class DepartmentOrganisationsController < ApplicationController
  def index
    @organisations = policy_scope(Organisation).where(department_id: params[:department_id])
                                               .where(id: current_agent.admin_organisations_ids)
  end
end
