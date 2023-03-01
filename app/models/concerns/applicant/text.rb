module Applicant::Text
  def full_name
    "#{title.capitalize} #{first_name.capitalize} #{last_name.upcase}"
  end

  def to_s
    "#{first_name.capitalize} #{last_name.capitalize}"
  end

  def short_title
    title == "monsieur" ? "M" : "Mme"
  end

  def conjugate(past_participle)
    madame? ? "#{past_participle}e" : past_participle
  end
end
