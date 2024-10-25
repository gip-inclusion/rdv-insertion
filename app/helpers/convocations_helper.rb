module ConvocationsHelper
  def convocations_by_format(convocations, formats)
    formats.index_with { |_| [] }.merge!(
      convocations
        # On affichera uniquement les infos de notification pour les convocations créées
        .select { |notif| notif.event == "participation_created" }
        .group_by(&:format)
        .slice(*formats)
        .transform_values { |convocs| convocs.sort_by(&:created_at).reverse }
    )
  end

  def max_number_of_convocations_in_any_format(convocations_by_format)
    convocations_by_format.values.map(&:count).max
  end
end
