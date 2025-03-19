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

  def tooltip_with_content(content)
    attributes = {
      data: {
        controller: "tooltip",
        action: "mouseover->tooltip#showContent",
        # We allow <br> and <b> tags in the tooltip content but we don't allow any other tags
        # and we don't allow any attributes on the tags to prevent any XSS attacks
        content: sanitize(content, tags: %w[br b], attributes: [])
      }
    }

    tag.attributes(attributes)
  end
end
