module User::AffiliationNumber
  extend ActiveSupport::Concern

  included do
    before_validation :format_affiliation_number, if: :affiliation_number?
  end

  private

  def format_affiliation_number
    remove_whitespaces
    return unless affiliation_number.length > 7

    remove_leading_zeros
    truncate_if_only_trailing_zeros
  end

  def remove_whitespaces
    self.affiliation_number = affiliation_number.gsub(/\s+/, "")
  end

  def remove_leading_zeros
    self.affiliation_number = affiliation_number.gsub(/\A0+/, "")
  end

  def truncate_if_only_trailing_zeros
    self.affiliation_number =
      affiliation_number[7..].gsub("0", "").empty? ? affiliation_number[0...7] : affiliation_number
  end
end
