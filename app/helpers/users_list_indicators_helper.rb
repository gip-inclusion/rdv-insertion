module UsersListIndicatorsHelper
  def creneau_availability_tooltip_content(creneau_availability)
    lines = ["Calculé le #{creneau_availability.created_at.strftime('%d/%m à %Hh%M')}"]
    period = display_date_period(
      creneau_availability.creneaux_available_from, creneau_availability.creneaux_available_until
    )
    lines.unshift("Pour la période #{period}") if period
    tooltip(content: safe_join(lines, tag.br))
  end

  def rdv_cancelled_or_absence_count(statuses_count)
    FollowUp::RDV_CANCELLED_OR_ABSENCE_STATUSES.sum { |status| statuses_count[status].to_i }
  end

  def follow_up_statuses_filter_active?(statuses)
    Array(params[:follow_up_statuses]).sort == statuses.sort
  end
end
