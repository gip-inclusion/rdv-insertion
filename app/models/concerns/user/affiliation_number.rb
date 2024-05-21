module User::AffiliationNumber
  extend ActiveSupport::Concern

  included do
    before_validation :format_affiliation_number, if: :affiliation_number?
  end

  private

  def format_affiliation_number
    # we remove leading zeros
    formated_number = affiliation_number.gsub(/\A0+/, "")
    self.affiliation_number = truncate_if_only_trailing_zeros(formated_number)
  end

  def truncate_if_only_trailing_zeros(str)
    str.length > 7 && str[7..].gsub("0", "").empty? ? str[0...7] : str
  end
end
