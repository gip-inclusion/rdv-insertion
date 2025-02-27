module TooltipHelper
  def tooltip_tag_attributes(stimulus_action:, **dataset)
    attributes = {
      data: {
        controller: "tooltip",
        action: stimulus_action
      }.merge(dataset || {})
    }

    tag.attributes(attributes)
  end

  def tooltip_errors_tag_attributes(title:, errors:)
    tag.attributes(tooltip_errors_attributes(title: title, errors: errors))
  end

  def tooltip_errors_attributes(title:, errors:)
    {
      data: {
        controller: "tooltip",
        action: "mouseover->tooltip#showErrors",
        title: title,
        errors: errors.to_json
      }
    }
  end
end
