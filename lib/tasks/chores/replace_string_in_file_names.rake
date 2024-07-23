require Rails.root.join("lib/chores/replace_string_in_file_names")

namespace :chores do
  desc <<-DESC
    Ce script renomme tous les dossiers et fichiers contenant la première expression en la remplaçant
    par la deuxième expression. C'est utile notamment lorsqu'on renomme une table

    bundle exec rails "chores:replace_string_in_file_names[expression_to_replace, replace_with]"
  DESC

  task :replace_string_in_file_names, [:expression_to_replace, :replace_with] => :environment do |t, args|
    expression_to_replace = args[:expression_to_replace]
    replace_with = args[:replace_with]

    puts "Are you sure you want to replace #{expression_to_replace} with #{replace_with} in all file names? (y/n)"
    confirm = gets.chomp == "y"

    Chores::ReplaceStringInFileNames.new(expression_to_replace, replace_with).call if confirm 
  end
end
