puts "Destroying..."

[Department, Agent].each(&:destroy_all)

puts "Creating departments..."

Department.create!(
  number: '08',
  name: 'Ardennes',
  capital: 'Charlevilles-Mézières'
)

Department.create!(
  number: '26',
  name: 'Drôme',
  capital: 'Valence'
)

puts "Creating agents..."
Agent.create!(email: "johndoe@gouv.fr", department: Department.last)

puts "Done!"
