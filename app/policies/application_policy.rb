class ApplicationPolicy
  attr_reader :pundit_user, :record

  def initialize(pundit_user, record)
    @pundit_user = pundit_user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    attr_reader :pundit_user, :scope

    def initialize(pundit_user, scope)
      @pundit_user = pundit_user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
