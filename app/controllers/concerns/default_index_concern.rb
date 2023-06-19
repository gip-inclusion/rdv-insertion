module DefaultIndexConcern
  private

  def default_index_path
    return path if structure.motif_categories.blank? || structure.motif_categories.count > 1

    "#{path}?motif_category_id=#{structure.motif_categories.first.id}"
  end

  def structure
    @structure ||= department_level? ? @department : @organisation
  end

  def path
    @path ||= department_level? ? department_applicants_path(@department) : organisation_applicants_path(@organisation)
  end
end
