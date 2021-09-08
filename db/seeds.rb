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
  region: "Auvergne-Rhône-Alpes",
  phone_number: "0147200001"
  # rdv_solidarites_organisation_id: insérez l'id de l'organisation correspondante sur RDV-Solidarites
)

puts "Creating agents..."
agent = Agent.create!(email: "johndoe@gouv.fr")
agent.department_ids = [Department.last.id]
agent.save!

puts "Creating configurations..."
Configuration.create!(
  sheet_name: "ENTRETIENS PHYSIQUES",
  invitation_format: "sms",
  department_id: Department.last.id,
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
