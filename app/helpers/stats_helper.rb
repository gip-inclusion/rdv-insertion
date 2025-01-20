module StatsHelper
  def options_for_department_select(departments)
    departments.map { |d| ["#{d.number} - #{d.name}", d.id] }
               .unshift(["Tous les départements", "0"])
  end

  def options_for_organisation_select(department)
    default_option = [["Sélection", [["Toutes les organisations", "0"]]]]
    grouped_organisations = department.organisations.reject { |o| disable_stats_for_organisation?(o) }
                                      .group_by(&:organisation_type)
                                      .map do |type, orgs|
      [
        type.humanize,
        orgs.map { |o| [o.name.to_s, o.id] }
      ]
    end
    default_option + grouped_organisations
  end

  def sanitize_monthly_data(stat)
    exclude_starting_zeros(exclude_current_month(stat))
  end

  def exclude_starting_zeros(stat)
    return unless stat

    stat.to_a.drop_while { |_, value| value.to_i.zero? }.to_h
  end

  def exclude_current_month(stat)
    exclude_months(stat, [Time.zone.now.strftime("%m/%Y")])
  end

  def exclude_current_and_previous_month(stat)
    exclude_months(stat, [1.month.ago.strftime("%m/%Y"), Time.zone.now.strftime("%m/%Y")])
  end

  def exclude_months(stat, months)
    stat&.delete_if { |key, _value| months.include?(key) }
  end

  private

  def organisation_ids_where_stats_disabled
    ENV.fetch("ORGANISATION_IDS_WHERE_STATS_DISABLED", "").split(",")
  end

  def disable_stats_for_organisation?(organisation)
    organisation_ids_where_stats_disabled.include?(organisation.id.to_s)
  end
end
