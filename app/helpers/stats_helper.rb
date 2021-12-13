module StatsHelper
  def options_for_department_select
    Department.all.order(:number).map { |d| ["#{d.number} - #{d.name}", d.number] }
              .unshift(["Tous les départements", "0"])
  end
end
