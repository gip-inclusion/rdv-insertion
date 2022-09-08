module StatsHelper
  def options_for_department_select
    Department.displayed_in_stats
              .order(:number)
              .map { |d| ["#{d.number} - #{d.name}", d.id] }
              .unshift(["Tous les départements", "0"])
  end
end
