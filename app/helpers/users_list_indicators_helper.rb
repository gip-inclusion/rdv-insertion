module UsersListIndicatorsHelper
  def creneau_availability_tooltip_content(creneau_availability)
    lines = ["Nombre de créneaux visibles par les usagers invités à prendre rendez-vous."]
    period = display_date_period(
      creneau_availability.creneaux_available_from, creneau_availability.creneaux_available_until
    )
    lines << "Visibilité #{period}." if period
    lines << "Nombre de créneaux calculé le #{creneau_availability.created_at.strftime('%d/%m à %Hh%M')}"
    tooltip(content: safe_join(lines, tag.br))
  end

  def rdv_cancelled_or_absence_count(statuses_count)
    FollowUp::RDV_CANCELLED_OR_ABSENCE_STATUSES.sum { |status| statuses_count[status].to_i }
  end

  def follow_up_statuses_filter_active?(statuses)
    Array(params[:follow_up_statuses]).sort == statuses.sort
  end

  def shortcut_url_params_for(statuses_filtering, active)
    if active
      url_params.merge(follow_up_statuses: url_params[:follow_up_statuses] - statuses_filtering)
    else
      url_params.merge(follow_up_statuses: statuses_filtering)
    end.except(:page)
  end
end
