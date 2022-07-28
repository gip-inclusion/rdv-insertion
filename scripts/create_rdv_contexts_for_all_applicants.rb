# rails runner scripts/create_rdv_contexts_for_all_applicants.rb

puts "Assigning contexts..."
puts "-----"
puts
Applicant.find_each do |applicant|
  puts "Assigning to applicant #{applicant.id}..."
  motif_categories = applicant.organisations.flat_map(&:motif_categories).uniq
  motif_categories.each do |motif_category|
    RdvContext.find_or_create_by!(applicant: applicant, motif_category: motif_category)
  end
end
puts "-----"
puts
puts "Contexts assigned!"
