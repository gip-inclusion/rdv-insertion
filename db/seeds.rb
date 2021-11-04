puts "Creating organisations..."

Department.create!(
  number: '08',
  name: 'Ardennes',
  capital: 'Charlevilles-Mézières'
)

Organisation.create!(
  name: "Plateforme mutualisée d'orientation",
  phone_number: "0147200001",
  department: Department.last.id
  # rdv_solidarites_organisation_id: insérez l'id de l'organisation correspondante sur RDV-Solidarites
)

puts "Creating agents..."
agent = Agent.create!(email: "johndoe@gouv.fr")
agent.organisation_ids = [Organisation.last.id]
agent.save!

puts "Creating configurations..."
Configuration.create!(
  sheet_name: "ENTRETIENS PHYSIQUES",
  invitation_format: "sms",
  organisation_id: Organisation.last.id,
  column_names: {
    "address"=>"adresse",
    "last_name"=>"nom-beneficiaire",
    "first_name"=>"prenom-beneficiaire",
    "email"=>"adresses-mails",
    "birth_date"=>"date-de-naissance",
    "postal_code"=>"cp-ville",
    "affiliation_number"=>"numero-allocataire",
    "role"=>"role",
    "phone_number"=>"numero-telephones"
  }
)

puts "Done!"
