module TooltipHelper
  def tooltip_errors(title:, errors:)
    tag.attributes(tooltip_errors_attributes(title: title, errors: errors))
  end

  def tooltip_errors_attributes(title:, errors:)
    tooltip_content = safe_join(
      [
        title,
        tag.br,
        safe_join(errors, tag.br)
      ]
    )
    tooltip_attributes(content: tooltip_content)
  end

  def tooltip(content:, placement: nil)
    tag.attributes(tooltip_attributes(content: content, placement: placement))
  end

  def tooltip_attributes(content:, placement: nil)
    {
      data: {
        controller: "tooltip",
        action: "mouseover->tooltip#showContent",
        placement: placement,
        # We allow <br>, <b>, <i>, <ul>, <li> tags in the tooltip content but we don't allow any other tags
        # and we don't allow any attributes on the tags to prevent any XSS attacks
        tooltip_content: sanitize(content, tags: %w[br b i ul li], attributes: [])
      }
    }
  end
end
