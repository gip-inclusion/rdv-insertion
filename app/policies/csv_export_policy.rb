class CsvExportPolicy < ApplicationPolicy
  def show?
    pundit_user == record.agent
  end
end
