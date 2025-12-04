module PdfIconsHelper
  def pdf_clock_icon(size: 14)
    content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", width: size, height: size, viewBox: "0 0 24 24",
                fill: "none", stroke: "currentColor", "stroke-width": "2",
                "stroke-linecap": "round", "stroke-linejoin": "round",
                style: "vertical-align: middle; margin-right: 4px;") do
      safe_join([
        tag(:circle, cx: "12", cy: "12", r: "10"),
        tag(:polyline, points: "12 6 12 12 16 14")
      ])
    end
  end

  def pdf_map_pin_icon(size: 14)
    content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", width: size, height: size, viewBox: "0 0 24 24",
                fill: "none", stroke: "currentColor", "stroke-width": "2",
                "stroke-linecap": "round", "stroke-linejoin": "round",
                style: "vertical-align: middle; margin-right: 4px;") do
      safe_join([
        tag(:path, d: "M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"),
        tag(:circle, cx: "12", cy: "10", r: "3")
      ])
    end
  end
end
