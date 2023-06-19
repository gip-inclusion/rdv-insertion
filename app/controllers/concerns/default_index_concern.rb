module DefaultIndexConcern
  private

  def default_index_path
    structure = department_level? ? @department : @organisation
    path = department_level? ? department_applicants_path(@department) : organisation_applicants_path(@organisation)
    return path if structure.motif_categories.blank? || structure.motif_categories.count > 1

    "#{path}?motif_category_id=#{structure.motif_categories.first.id}"
  end
end
