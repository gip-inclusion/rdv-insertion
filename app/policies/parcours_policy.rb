class ParcoursPolicy < ApplicationPolicy
  def show?
    record.number.in?(ENV["DEPARTMENTS_WHERE_PARCOURS_ENABLED"].split(","))
  end
end
