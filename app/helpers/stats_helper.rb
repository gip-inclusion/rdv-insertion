module StatsHelper
  def options_for_department_select
    ardennes = Department.find_by(name: "Ardennes")
    Department.all
              .order(:number)
              .excluding(ardennes)
              .map { |d| ["#{d.number} - #{d.name}", d.number] }
              .unshift(["Tous les départements", "0"])
  end
end
