class RdvContextPolicy < ApplicationPolicy
  def create?
    pundit_user.department_ids.include?(record.applicant&.department_id)
  end

  class Scope < Scope
    def resolve
      RdvContext.where(applicant_id: pundit_user.applicants.map(&:id))
                .where(motif_category: pundit_user.configurations.map(&:motif_category).uniq)
    end
  end
end
