module ApplicantsHelper
  def format_date(date)
    date&.strftime("%d/%m/%Y")
  end

  def display_attribute(attribute)
    attribute || " - "
  end

  def display_back_to_list_button?
    params[:search_query].present?
  end
end
