module ApplicantsHelper
  def birth_date_formatted(birth_date)
    birth_date&.strftime("%d/%m/%Y")
  end

  def display_attribute(attribute)
    attribute || " - "
  end
end
