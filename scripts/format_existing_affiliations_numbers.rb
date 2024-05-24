# rails runner scripts/format_existing_affiliations_numbers.rb
# This script is used to format existing affiliation numbers

ActiveRecord::Base.transaction do
  users_with_more_than_seven_chars = User.where("LENGTH(affiliation_number) > 7")
  puts "Found #{users_with_more_than_seven_chars.count} users with more than 7 characters in their affiliation number."

  users_with_leading_zeros = users_with_more_than_seven_chars.where("affiliation_number LIKE ?", "0%")
  puts "Found #{users_with_leading_zeros.count} users with leading zeros in their affiliation number."

  users_with_only_zeros_after_seventh =
    users_with_more_than_seven_chars.where("SUBSTRING(affiliation_number FROM 8) ~ ?", "^0*$")
  puts "Found #{users_with_only_zeros_after_seventh.count} users with only zeros after the seventh character in their
    affiliation number."

  users_to_format =
    users_with_more_than_seven_chars.where(
      id: users_with_leading_zeros.select(:id) + users_with_only_zeros_after_seventh.select(:id)
    )
  puts "Found #{users_to_format.count} users to format."

  puts "Starting formating..."

  users_to_format.each do |user|
    user.send(:format_affiliation_number)
    user.save!
  end

  puts "Finished formating. Starting verification..."

  users_with_more_than_seven_chars = User.where("LENGTH(affiliation_number) > 7")
  puts "Found #{users_with_more_than_seven_chars.count} users with more than 7 characters in their affiliation number."

  users_with_leading_zeros = users_with_more_than_seven_chars.where("affiliation_number LIKE ?", "0%")
  puts "Found #{users_with_leading_zeros.count} users with leading zeros in their affiliation number."

  users_with_only_zeros_after_seventh =
    users_with_more_than_seven_chars.where(
      "LENGTH(affiliation_number) > 7 AND SUBSTRING(affiliation_number FROM 8) ~ ?", "^0*$"
    )
  puts "Found #{users_with_only_zeros_after_seventh.count} users with only zeros after the seventh character in their
    affiliation number."

  users_to_format =
    users_with_more_than_seven_chars.where(
      id: users_with_leading_zeros.select(:id) + users_with_only_zeros_after_seventh.select(:id)
    )
  puts "Found #{users_to_format.count} users to format."

  raise "Rolling back after dry run - add COMMIT to commit the transaction!" unless ARGV[0] == "COMMIT"
end
