class ApplicantPolicy < ApplicationPolicy
  def index?
    show?
  end

  def new?
    show?
  end

  def invite?
    show?
  end

  def create?
    show?
  end

  def show?
    (pundit_user.organisation_ids & record.organisation_ids).any?
  end

  def update?
    show?
  end

  def search?
    show?
  end

  def edit?
    show?
  end
end
