class ParcoursPolicy < ApplicationPolicy
  def index?
    record.number.in?(ENV["DEPARTMENTS_WHERE_PARCOURS_ENABLED"].split(","))
  end
end
