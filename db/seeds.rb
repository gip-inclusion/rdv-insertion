# Rappel : rdv-solidarités doit être installé et tourner en local pour obtenir un environnement de dev fonctionnel
# Le code de rdv-solidarités peut être trouvé ici : https://github.com/betagouv/rdv-solidarites.fr/
# Il n'y a pas d'agent créé ici : les agents utilisateurs de rdv-insertion sont récupérés de rdv-solidarités

# Pour utiliser rdv-insertion proprement en local, en plus de ces seeds, il est nécessaire de créer sur rdv-s :
# - les territories et organisations correspondant aux départments et organisations créés ci-dessous
# - rattacher l'agent aux organisations via un AgentRole (level: "admin")
# - configurer les webhooks de chaque organisation

# Les seeds de rdv-solidarités permettent de créer ces différents éléments
# L'agent à utiliser est alors "Alain Sertion"
  # email: "alain.sertion@rdv-insertion-demo.fr",
  # password: "123456",
# Les rdv_solidarites_organisation_id sont configurées pour match ces seeds, mais il est préférable de les vérifier



# --------------------------------------------------------------------------------------------------------------------
puts "Creating departments..."
# La Drôme permet de tester plusieurs organisations, plusieurs contextes et tous les formats d'invitation
drome = Department.create!(
  name: "Drôme",
  number: "26",
  capital: "Valence",
  region: "Auvergne-Rhône-Alpes",
  pronoun: "la",
)

# Dans l'Yonne, pas de système d'invitation : les bénéficiaires sont directement convoqués (notify_applicant: true)
yonne = Department.create!(
  name: "Yonne",
  number: "89",
  capital: "Auxerre",
  region: "Bourgogne-Franche-Comté",
  pronoun: "l'",
)

# --------------------------------------------------------------------------------------------------------------------
puts "Creating configurations and responsible..."
drome_orientation_config = Configuration.create!(
  sheet_name: "ENTRETIENS PHYSIQUES",
  column_names:
    {"required"=>
      {"address"=>"Adresse",
      "last_name"=>"Nom bénéficiaire",
      "first_name"=>"Prénom bénéficiaire",
      "email"=>"Adresses Mails",
      "birth_date"=>"Date de Naissance",
      "postal_code"=>"CP Ville",
      "affiliation_number"=>"N° Allocataire",
      "role"=>"Rôle",
      "phone_number"=>"N° Téléphones",
      "title"=>"Civilité"},
    "optional"=>{"department_internal_id"=>"ID Iodas"}},
  notify_applicant: false,
  invitation_formats: ["sms", "email", "postal"],
  motif_category: "rsa_orientation",
  number_of_days_to_accept_invitation: 3,
  number_of_days_before_action_required: 3
)

drome_accompagnement_config = Configuration.create!(
  sheet_name: "ENTRETIENS PHYSIQUES",
  column_names:
    {"required"=>
      {"address"=>"Adresse",
      "last_name"=>"Nom bénéficiaire",
      "first_name"=>"Prénom bénéficiaire",
      "email"=>"Adresses Mails",
      "birth_date"=>"Date de Naissance",
      "postal_code"=>"CP Ville",
      "affiliation_number"=>"N° Allocataire",
      "role"=>"Rôle",
      "phone_number"=>"N° Téléphones",
      "title"=>"Civilité"},
    "optional"=>{"department_internal_id"=>"ID Iodas"}},
  notify_applicant: false,
  invitation_formats: ["sms", "email", "postal"],
  motif_category: "rsa_accompagnement",
  number_of_days_to_accept_invitation: 3,
  number_of_days_before_action_required: 3
)

yonne_orientation_config = Configuration.create!(
  sheet_name: "Feuille1",
  column_names:
    {"required"=>
      {"affiliation_number"=>"N° Allocataire",
      "last_name"=>"Nom",
      "first_name"=>"Prénom",
      "phone_number"=>"Numéro(s) de téléphone",
      "full_address"=>"Adresse",
      "birth_date"=>"Date de naissance",
      "role"=>"Rôle",
      "title"=>"Civilité"},
    "optional"=>{"birth_name"=>"Nom JF", "department_internal_id"=>"Code individu Iodas"}},
  notify_applicant: true,
  invitation_formats: [],
  motif_category: "rsa_orientation",
  number_of_days_to_accept_invitation: 3,
  number_of_days_before_action_required: 3
)

invitation_parameters = InvitationParameters.create!(
  direction_names:
    ["DIRECTION GÉNÉRALE DES SERVICES DÉPARTEMENTAUX",
    "DIRECTION DE L’INSERTION ET DU RETOUR À L’EMPLOI",
    "SERVICE ORIENTATION ET ACCOMPAGNEMENT VERS L’EMPLOI"]
)

# --------------------------------------------------------------------------------------------------------------------
puts "Creating organisations..."
drome1_organisation = Organisation.create!(
  name: "Plateforme mutualisée d'orientation",
  phone_number: "0475796991",
  rdv_solidarites_organisation_id: 3,
  # rdv_solidarites_organisation_id: vérifier l'id de l'organisation correspondante sur RDV-Solidarites
  department_id: drome.id,
  configuration_ids: [drome_orientation_config.id, drome_accompagnement_config.id],
  invitation_parameters_id: invitation_parameters.id
)

drome2_organisation = Organisation.create!(
  name: "PLIE Valence",
  phone_number: "0101010102",
  rdv_solidarites_organisation_id: 4,
  # rdv_solidarites_organisation_id: vérifier l'id de l'organisation correspondante sur RDV-Solidarites
  department_id: drome.id,
  configuration_ids: [drome_orientation_config.id, drome_accompagnement_config.id],
  invitation_parameters_id: invitation_parameters.id
)

yonne_organisation = Organisation.create!(
  name: "UT Avallon",
  phone_number: "0303030303",
  rdv_solidarites_organisation_id: 5,
  # rdv_solidarites_organisation_id: vérifier l'id de l'organisation correspondante sur RDV-Solidarites
  department_id: yonne.id,
  configuration_ids: [yonne_orientation_config.id],
  invitation_parameters_id: invitation_parameters.id
)

puts "Done!"
