# Rappel : rdv-solidarités doit être installé et tourner en local pour obtenir un environnement de dev fonctionnel
# Le code de rdv-solidarités peut être trouvé ici : https://github.com/betagouv/rdv-solidarites.fr/
# Il n'y a pas d'agent créé ici : les agents utilisateurs de rdv-insertion sont récupérés de rdv-solidarités

# Pour utiliser rdv-insertion proprement en local, en plus de ces seeds, il est nécessaire de créer sur rdv-s :
# - les territories et organisations correspondant aux départments et organisations créés ci-dessous
# - rattacher l'agent aux organisations via un AgentRole (access_level: "admin")
# - configurer les webhooks de chaque organisation

# Les seeds de rdv-solidarités permettent de créer ces différents éléments
# L'agent à utiliser est alors "Alain Sertion"
  # email: "alain.sertion@rdv-insertion-demo.fr"
# Les rdv_solidarites_organisation_id sont configurées pour match ces seeds, mais il est préférable de les vérifier

if Agent.exists?(email: "alain.sertion@rdv-insertion-demo.fr")
  puts "Les seeds ont déjà été exécutées, il n'est pas nécessaire de les relancer."
  exit(0)
end

# --------------------------------------------------------------------------------------------------------------------
puts "Creating departments..."
# La Drôme permet de tester plusieurs organisations, plusieurs contextes et tous les formats d'invitation
drome = Department.create!(
  name: "Drôme",
  number: "26",
  capital: "Valence",
  region: "Auvergne-Rhône-Alpes",
  pronoun: "la",
  logo: Rack::Test::UploadedFile.new(Rails.root.join("app/assets/images/logos/france-travail.png"))
)

# Dans l'Yonne, pas de système d'invitation : les bénéficiaires sont directement convoqués (convene_user: true)
yonne = Department.create!(
  name: "Yonne",
  number: "89",
  capital: "Auxerre",
  region: "Bourgogne-Franche-Comté",
  pronoun: "l'",
  logo: Rack::Test::UploadedFile.new(Rails.root.join("app/assets/images/logos/france-travail.png"))
)

# --------------------------------------------------------------------------------------------------------------------
puts "Creating motif categories..."
orientation_category = MotifCategory.create!(
  name: "RSA orientation",
  short_name: "rsa_orientation",
  motif_category_type: "rsa_orientation",
  template: Template.find_or_create_by!(
    model: "standard",
    rdv_title: "rendez-vous d'orientation",
    rdv_title_by_phone: "rendez-vous d'orientation téléphonique",
    rdv_purpose: "démarrer un parcours d'accompagnement",
    user_designation: "bénéficiaire du RSA",
    rdv_subject: "RSA",
    display_mandatory_warning: true
  )
)
accompagnement_category = MotifCategory.create!(
  name: "RSA accompagnement",
  short_name: "rsa_accompagnement",
  motif_category_type: "rsa_accompagnement",
  template: Template.find_or_create_by!(
    model: "standard",
    rdv_title: "rendez-vous d'accompagnement",
    rdv_title_by_phone: "rendez-vous d'accompagnement téléphonique",
    rdv_purpose: "démarrer un parcours d'accompagnement",
    user_designation: "bénéficiaire du RSA",
    rdv_subject: "RSA",
    display_mandatory_warning: true,
    punishable_warning: "votre RSA pourra être suspendu ou réduit"
  )
)
MotifCategory.create!(
  name: "RSA accompagnement socio-pro",
  short_name: "rsa_accompagnement_sociopro",
  motif_category_type: "rsa_accompagnement",
  template: Template.find_or_create_by!(
    model: "standard",
    rdv_title: "rendez-vous d'accompagnement",
    rdv_title_by_phone: "rendez-vous d'accompagnement téléphonique",
    rdv_purpose: "démarrer un parcours d'accompagnement",
    user_designation: "bénéficiaire du RSA",
    rdv_subject: "RSA",
    display_mandatory_warning: true,
    punishable_warning: "votre RSA pourra être suspendu ou réduit"
  )
)
MotifCategory.create!(
  name: "RSA accompagnement social",
  short_name: "rsa_accompagnement_social",
  motif_category_type: "rsa_accompagnement",
  template: Template.find_or_create_by!(
    model: "standard",
    rdv_title: "rendez-vous d'accompagnement",
    rdv_title_by_phone: "rendez-vous d'accompagnement téléphonique",
    rdv_purpose: "démarrer un parcours d'accompagnement",
    user_designation: "bénéficiaire du RSA",
    rdv_subject: "RSA",
    display_mandatory_warning: true,
    punishable_warning: "votre RSA pourra être suspendu ou réduit"
  )
)
MotifCategory.create!(
  name: "RSA signature CER",
  short_name: "rsa_cer_signature",
  motif_category_type: "rsa_accompagnement",
  template: Template.find_or_create_by!(
    model: "standard",
    rdv_title: "rendez-vous de signature de CER",
    rdv_title_by_phone: "rendez-vous téléphonique de signature de CER",
    rdv_purpose: "construire et signer votre Contrat d'Engagement Réciproque",
    user_designation: "bénéficiaire du RSA",
    rdv_subject: "RSA",
    display_mandatory_warning: true
  )
)
MotifCategory.create!(
  name: "RSA suivi",
  short_name: "rsa_follow_up",
  motif_category_type: "rsa_accompagnement",
  template: Template.find_or_create_by!(
    model: "standard",
    rdv_title: "rendez-vous de suivi",
    rdv_title_by_phone: "rendez-vous de suivi téléphonique",
    rdv_purpose: "faire un point avec votre référent de parcours",
    user_designation: "bénéficiaire du RSA",
    rdv_subject: "RSA",
    display_mandatory_warning: false,
  )
)
MotifCategory.create!(
  name: "RSA offre insertion pro",
  short_name: "rsa_insertion_offer",
  motif_category_type: "rsa_accompagnement",
  template: Template.find_or_create_by!(
    model: "atelier",
    rdv_title: "atelier",
    rdv_title_by_phone: "atelier téléphonique",
    rdv_subject: "RSA",
    user_designation: "bénéficiaire du RSA"
  )
)

MotifCategory.create!(
  name: "RSA orientation sur plateforme téléphonique",
  short_name: "rsa_orientation_on_phone_platform",
  motif_category_type: "rsa_orientation",
  template: Template.find_or_create_by!(
    model: "phone_platform",
    rdv_title: "rendez-vous d'orientation téléphonique",
    rdv_title_by_phone: "rendez-vous d'orientation téléphonique",
    rdv_subject: "RSA",
    user_designation: "bénéficiaire du RSA",
    rdv_purpose: "démarrer un parcours d'accompagnement"
  )
)
MotifCategory.create!(
  name: "RSA Atelier collectif obligatoire",
  short_name: "rsa_atelier_collectif_mandatory",
  motif_category_type: "rsa_accompagnement",
  template: Template.find_or_create_by!(
    model: "standard",
    rdv_title: "atelier collectif",
    rdv_title_by_phone: "atelier collectif",
    rdv_purpose: "vous aider dans votre parcours d'insertion",
    user_designation: "bénéficiaire du RSA",
    rdv_subject: "RSA",
    display_mandatory_warning: true
  )
)
MotifCategory.create!(
  name: "RSA Atelier rencontres professionnelles",
  short_name: "rsa_atelier_rencontres_pro",
  motif_category_type: "rsa_accompagnement",
  template: Template.find_or_create_by!(
    model: "atelier",
    rdv_title: "atelier",
    rdv_title_by_phone: "atelier téléphonique",
    rdv_subject: "RSA",
    user_designation: "bénéficiaire du RSA"
  )
)
MotifCategory.create!(
  name: "RSA Atelier compétences",
  short_name: "rsa_atelier_competences",
  motif_category_type: "rsa_accompagnement",
  template: Template.find_or_create_by!(
    model: "atelier",
    rdv_title: "atelier",
    rdv_title_by_phone: "atelier téléphonique",
    rdv_subject: "RSA",
    user_designation: "bénéficiaire du RSA"
  )
)
MotifCategory.create!(
  name: "RSA Main Tendue",
  short_name: "rsa_main_tendue",
  motif_category_type: "rsa_accompagnement",
  template: Template.find_or_create_by!(
    model: "standard",
    rdv_title: "entretien de main tendue",
    rdv_title_by_phone: "entretien téléphonique de main tendue",
    rdv_purpose: "faire le point sur votre situation",
    user_designation: "bénéficiaire du RSA",
    rdv_subject: "RSA",
    display_mandatory_warning: true
  )
)
MotifCategory.create!(
  name: "RSA SPIE",
  short_name: "rsa_spie",
  motif_category_type: "rsa_accompagnement",
  template: Template.find_or_create_by!(
    model: "standard",
    rdv_title: "rendez-vous d'accompagnement",
    rdv_title_by_phone: "rendez-vous d'accompagnement téléphonique",
    rdv_purpose: "démarrer un parcours d'accompagnement",
    user_designation: "demandeur d'emploi",
    rdv_subject: "demande d'emploi",
    display_mandatory_warning: true,
    punishable_warning: "votre RSA pourra être suspendu ou réduit"
  )
)
MotifCategory.create!(
  name: "RSA Information d'intégration",
  short_name: "rsa_integration_information",
  motif_category_type: "autre",
  template: Template.find_or_create_by!(
    model: "standard",
    rdv_title: "rendez-vous d'information",
    rdv_title_by_phone: "rendez-vous d'information téléphonique",
    user_designation: "bénéficiaire du RSA",
    rdv_subject: "RSA",
    rdv_purpose: "vous renseigner sur vos droits et vos devoirs",
    display_mandatory_warning: true
  )
)

# --------------------------------------------------------------------------------------------------------------------
puts "Creating file category_configurations..."
file_config_drome = FileConfiguration.create(
  sheet_name: "ENTRETIENS PHYSIQUES",
  address_first_field_column: "Adresse",
  last_name_column: "Nom bénéficiaire",
  first_name_column: "Prénom bénéficiaire",
  email_column: "Adresses Mails",
  birth_date_column: "Date de Naissance",
  address_fifth_field_column: "CP Ville",
  affiliation_number_column: "N° CAF",
  role_column: "Rôle",
  phone_number_column: "N° Téléphones",
  title_column: "Civilité",
  department_internal_id_column: "ID Iodas"
)

file_config_yonne = FileConfiguration.create(
  sheet_name: "Feuille1",
  affiliation_number_column: "N° CAF",
  last_name_column: "Nom",
  first_name_column: "Prénom",
  phone_number_column: "Numéro(s) de téléphone",
  address_first_field_column: "Adresse",
  birth_date_column: "Date de naissance",
  role_column: "Rôle",
  title_column: "Civilité",
  birth_name_column: "Nom JF",
  department_internal_id_column: "Code individu Iodas"
)

# --------------------------------------------------------------------------------------------------------------------
puts "Creating organisations and category_configurations..."
drome1_organisation = Organisation.create!(
  name: "Plateforme mutualisée d'orientation",
  phone_number: "0475796991",
  rdv_solidarites_organisation_id: 1,
  # rdv_solidarites_organisation_id: vérifier l'id de l'organisation correspondante sur RDV-Solidarites
  department_id: drome.id,
  organisation_type: "conseil_departemental"
)

CategoryConfiguration.create!(
  file_configuration: file_config_drome,
  convene_user: true,
  invitation_formats: ["sms", "email", "postal"],
  motif_category: orientation_category,
  number_of_days_before_invitations_expire: 10,
  organisation: drome1_organisation
)

CategoryConfiguration.create!(
  file_configuration: file_config_drome,
  convene_user: false,
  invitation_formats: ["sms", "email", "postal"],
  motif_category: accompagnement_category,
  number_of_days_before_invitations_expire: 10,
  organisation: drome1_organisation
)

drome1_organisation.messages_configuration.update!(
  direction_names:
    ["DIRECTION GÉNÉRALE DES SERVICES DÉPARTEMENTAUX",
    "DIRECTION DE L’INSERTION ET DU RETOUR À L’EMPLOI",
    "SERVICE ORIENTATION ET ACCOMPAGNEMENT VERS L’EMPLOI"]
)

drome2_organisation = Organisation.create!(
  name: "PLIE Valence",
  phone_number: "0101010102",
  rdv_solidarites_organisation_id: 2,
  # rdv_solidarites_organisation_id: vérifier l'id de l'organisation correspondante sur RDV-Solidarites
  department_id: drome.id,
  organisation_type: "france_travail"
)

CategoryConfiguration.create!(
  file_configuration: file_config_drome,
  convene_user: false,
  invitation_formats: ["sms", "email", "postal"],
  motif_category: orientation_category,
  number_of_days_before_invitations_expire: 10,
  organisation: drome2_organisation
)

CategoryConfiguration.create!(
  file_configuration: file_config_drome,
  convene_user: false,
  invitation_formats: ["sms", "email", "postal"],
  motif_category: accompagnement_category,
  number_of_days_before_invitations_expire: 10,
  organisation: drome2_organisation
)

drome2_organisation.messages_configuration.update!(
  direction_names:
    ["DIRECTION GÉNÉRALE DES SERVICES DÉPARTEMENTAUX",
    "DIRECTION DE L’INSERTION ET DU RETOUR À L’EMPLOI",
    "SERVICE ORIENTATION ET ACCOMPAGNEMENT VERS L’EMPLOI"]
)

yonne_organisation = Organisation.create!(
  name: "UT Avallon",
  phone_number: "0303030303",
  rdv_solidarites_organisation_id: 3,
  # rdv_solidarites_organisation_id: vérifier l'id de l'organisation correspondante sur RDV-Solidarites
  department_id: yonne.id,
  organisation_type: "france_travail"
)

CategoryConfiguration.create!(
  file_configuration: file_config_yonne,
  convene_user: true,
  invitation_formats: [],
  motif_category: orientation_category,
  number_of_days_before_invitations_expire: 10,
  organisation: yonne_organisation
)

yonne_organisation.messages_configuration.update!(
  direction_names:
    ["DIRECTION GÉNÉRALE DES SERVICES DÉPARTEMENTAUX",
    "DIRECTION DE L’INSERTION ET DU RETOUR À L’EMPLOI",
    "SERVICE ORIENTATION ET ACCOMPAGNEMENT VERS L’EMPLOI"]
)

OrientationType.create!(casf_category: "social", name: "Sociale")
OrientationType.create!(casf_category: "pro", name: "Professionnelle")
OrientationType.create!(casf_category: "socio_pro", name: "Socio-professionnelle")

# --------------------------------------------------------------------------------------------------------------------
puts "Creating agent and motifs..."
# Faking Webhooks entries (for avoiding resending them from rdv solidarites manually), update ids from rdv-s if rdv solidarite seed is changing

agent = Agent.create!(
  email: "alain.sertion@rdv-insertion-demo.fr",
  rdv_solidarites_agent_id: 1,
  # rdv_solidarites_agent_id: vérifier l'id de l'agent correspondant sur RDV-Solidarites
  first_name: "Alain",
  last_name: "Sertion",
  last_sign_in_at: Time.zone.now,
  last_webhook_update_received_at: Time.zone.now
)

agent.update_column(:super_admin, true)

AgentRole.create!(agent:, organisation: drome1_organisation, access_level: "admin")
AgentRole.create!(agent:, organisation: drome2_organisation, access_level: "admin")
AgentRole.create!(agent:, organisation: yonne_organisation, access_level: "admin")

user_to_convoc = User.create!(
  rdv_solidarites_user_id: 1,
  email: "jean.rsavalence@testinvitation.fr",
  first_name: "Jean",
  last_name: "RSAValence",
  title: "monsieur",
  address: "60 avenue de Chabeuil 26000 Valence",
  phone_number: "0601020304",
  created_from_structure: drome1_organisation,
  created_through: "rdv_insertion_api"
)

follow_up_for_jean = FollowUp.create!(user: user_to_convoc, motif_category: orientation_category)

Invitation.create!(
  user: user_to_convoc,
  department: drome,
  organisations: [drome1_organisation],
  expires_at: Time.zone.now - 10.days,
  created_at: Time.zone.now - 15.days,
  updated_at: Time.zone.now - 15.days,
  format: "email",
  link: "https://expired.rdv-insertion/link",
  rdv_solidarites_token: "EXPIRED",
  clicked: false,
  help_phone_number: "0123456789",
  rdv_solidarites_lieu_id: nil,
  follow_up: follow_up_for_jean,
  rdv_with_referents: false,
  trigger: "manual",
  delivery_status: nil,
  last_brevo_webhook_received_at: nil
)


User.create!(
  rdv_solidarites_user_id: 2,
  email: "jean.rsaAuxerre@testinvitation.fr",
  address: "12 Rue Joubert, Auxerre, 89000",
  first_name: "Jean",
  last_name: "RSAAuxerre",
  title: "monsieur",
  created_from_structure: yonne_organisation,
  created_through: "rdv_insertion_api"
)

Motif.create!(
  rdv_solidarites_motif_id: 1,
  # rdv_solidarites_motif_id: vérifier l'id du motif correspondant sur RDV-Solidarites
  name: "RSA - Orientation : rdv sur site",
  reservable_online: true,
  rdv_solidarites_service_id: 1,
  # rdv_solidarites_service_id: vérifier l'id du service correspondant sur RDV-Solidarites
  collectif: false,
  location_type: "public_office",
  motif_category: orientation_category,
  last_webhook_update_received_at: Time.zone.now,
  organisation_id: drome1_organisation.id,
  follow_up: false
)

Motif.create!(
  rdv_solidarites_motif_id: 2,
  # rdv_solidarites_motif_id: vérifier l'id du motif correspondant sur RDV-Solidarites
  name: "RSA accompagnement",
  reservable_online: true,
  deleted_at: nil,
  rdv_solidarites_service_id: 1,
  # rdv_solidarites_service_id: vérifier l'id du service correspondant sur RDV-Solidarites
  collectif: false,
  location_type: "public_office",
  motif_category: accompagnement_category,
  last_webhook_update_received_at: Time.zone.now,
  organisation_id: drome1_organisation.id,
  follow_up: false
)

Motif.create!(
  rdv_solidarites_motif_id: 4,
  # rdv_solidarites_motif_id: vérifier l'id du motif correspondant sur RDV-Solidarites
  name: "Convocation RSA - Orientation : rdv sur site",
  reservable_online: false,
  deleted_at: nil,
  rdv_solidarites_service_id: 1,
  # rdv_solidarites_service_id: vérifier l'id du service correspondant sur RDV-Solidarites
  collectif: false,
  location_type: "public_office",
  motif_category: orientation_category,
  last_webhook_update_received_at: Time.zone.now,
  organisation_id: drome1_organisation.id,
  follow_up: false
)

Lieu.create!( # Nécessaire pour la convoc
  rdv_solidarites_lieu_id: 2,
  name: "Le 114 - Plate -forme mutualisée d'orientation - Département de la Drôme",
  address: "114 Rue de la Forêt, Valence, 26000",
  phone_number: "04.75.79.69.91",
  organisation: drome1_organisation
)

Motif.create!(
  rdv_solidarites_motif_id: 3,
  # rdv_solidarites_motif_id: vérifier l'id du motif correspondant sur RDV-Solidarites
  name: "RSA - Orientation : rdv sur site",
  reservable_online: true,
  deleted_at: nil,
  rdv_solidarites_service_id: 1,
  # rdv_solidarites_service_id: vérifier l'id du service correspondant sur RDV-Solidarites
  collectif: false,
  location_type: "public_office",
  motif_category: orientation_category,
  last_webhook_update_received_at: Time.zone.now,
  organisation_id: drome2_organisation.id,
  follow_up: false
)

Motif.create!(
  rdv_solidarites_motif_id: 5,
  # rdv_solidarites_motif_id: vérifier l'id du motif correspondant sur RDV-Solidarites
  name: "RSA - Codiagnostic d'orientation",
  reservable_online: false,
  deleted_at: nil,
  rdv_solidarites_service_id: 1,
  # rdv_solidarites_service_id: vérifier l'id du service correspondant sur RDV-Solidarites
  collectif: false,
  location_type: "public_office",
  motif_category: orientation_category,
  last_webhook_update_received_at: Time.zone.now,
  organisation_id: yonne_organisation.id,
  follow_up: false
)

Motif.create!(
  rdv_solidarites_motif_id: 6,
  # rdv_solidarites_motif_id: vérifier l'id du motif correspondant sur RDV-Solidarites
  name: "RSA - Orientation : rdv téléphonique",
  reservable_online: false,
  deleted_at: nil,
  rdv_solidarites_service_id: 1,
  # rdv_solidarites_service_id: vérifier l'id du service correspondant sur RDV-Solidarites
  collectif: false,
  location_type: "phone",
  motif_category: orientation_category,
  last_webhook_update_received_at: Time.zone.now,
  organisation_id: yonne_organisation.id,
  follow_up: false
)

# --------------------------------------------------------------------------------------------------------------------
puts "Creating stats..."

Stat.create!(statable_type: "Department")
Stat.create!(statable: yonne)
Stat.create!(statable: drome)
Stat.create!(statable: yonne_organisation)
Stat.create!(statable: drome1_organisation)
Stat.create!(statable: drome2_organisation)
