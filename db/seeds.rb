puts "Creating organisations..."

Department.create!(
  number: '08',
  name: 'Ardennes',
  capital: 'Charlevilles-Mézières',
  pronoun: "les"
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
    required: {
      "address"=>"Adresse",
      "last_name"=>"Nom bénéficiaire",
      "first_name"=>"Prénom bénéficiaire",
      "email"=>"Adresses mails",
      "birth_date"=>"Date de naissance",
      "postal_code"=>"CP Ville",
      "affiliation_number"=>"N° Allocataire",
      "role"=>"Rôle",
      "phone_number"=>"N° Téléphones",
      "title"=>"Civilité"
    },
    optional: {
      "department_internal_id"=>"Code individu IODAS"
    }
  }
)

puts "Done!"
