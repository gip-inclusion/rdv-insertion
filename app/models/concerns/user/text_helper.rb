module User::TextHelper
  def full_name
    "#{short_title.capitalize} #{first_name.capitalize} #{last_name.upcase}"
  end

  def to_s
    "#{first_name&.capitalize} #{last_name&.capitalize}".strip
  end

  def short_title
    return "" if title.blank?

    title == "monsieur" ? "M." : "Mme"
  end

  def full_name_stripped
    "#{short_title&.capitalize} #{first_name&.capitalize} #{last_name&.upcase}".strip
  end

  def conjugate(past_participle)
    case title
    when "monsieur"
      past_participle
    when "madame"
      "#{past_participle}e"
    else
      "#{past_participle}(e)"
    end
  end

  def title_in_letter
    title&.capitalize || "Madame, Monsieur"
  end
end
