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
  capital: 'Valence',
  # rdv_solidarites_organisation_id: insérez l'id de l'organisation correspondante sur RDV-Solidarites
)

puts "Creating agents..."
Agent.create!(email: "johndoe@gouv.fr", department: Department.last)

puts "Done!"
