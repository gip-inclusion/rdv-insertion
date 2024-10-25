module ConvocationsHelper
  def convocations_by_format(convocations, formats)
    default_formats = formats.index_with { |_| [] }

    grouped_convocations = convocations
                           .group_by(&:format)
                           .select { |format| formats.include?(format) }
                           .transform_values { |notifications| latest_notifications_by_rdv(notifications) }

    default_formats.merge!(grouped_convocations)
  end

  def max_number_of_convocations_in_any_format(convocations_by_format)
    convocations_by_format.values.map(&:count).max
  end

  private

  def latest_notifications_by_rdv(notifications)
    # On peut recevoir plusieurs notifications pour un même format et une même convocation (créé puis annulé par ex)
    # On affichera uniquement la dernière notification de convocation pour chaque rdv
    notifications
      .group_by(&:rdv_solidarites_rdv_id)
      .values
      .map { |rdv_notifications| rdv_notifications.max_by(&:created_at) }
      .sort_by(&:created_at)
      .reverse
  end
end
