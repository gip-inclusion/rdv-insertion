# rubocop:disable Metrics/ClassLength
class CreateTemplates < ActiveRecord::Migration[7.0]
  TEMPLATE_ATTRIBUTES_BY_CATEGORY_SHORT_NAME = {
    "rsa_orientation" => {
      "model" => "standard",
      "rdv_title" => "rendez-vous d'orientation",
      "rdv_title_by_phone" => "rendez-vous d'orientation téléphonique",
      "rdv_purpose" => "démarrer un parcours d'accompagnement",
      "applicant_designation" => "bénéficiaire du RSA",
      "rdv_subject" => "RSA",
      "display_mandatory_warning" => true
    },
    "rsa_orientation_on_phone_platform" => {
      "model" => "phone_platform",
      "rdv_title" => "rendez-vous d'orientation téléphonique",
      "rdv_subject" => "RSA",
      "applicant_designation" => "bénéficiaire du RSA",
      "rdv_purpose" => "démarrer un parcours d'accompagnement"
    },
    "rsa_accompagnement" => {
      "model" => "standard",
      "rdv_title" => "rendez-vous d'accompagnement",
      "rdv_title_by_phone" => "rendez-vous d'accompagnement téléphonique",
      "rdv_purpose" => "démarrer un parcours d'accompagnement",
      "applicant_designation" => "bénéficiaire du RSA",
      "rdv_subject" => "RSA",
      "display_mandatory_warning" => true,
      "punishable_warning" => "votre RSA pourra être suspendu ou réduit"
    },
    "rsa_accompagnement_social" => {
      "model" => "standard",
      "rdv_title" => "rendez-vous d'accompagnement",
      "rdv_title_by_phone" => "rendez-vous d'accompagnement téléphonique",
      "rdv_purpose" => "démarrer un parcours d'accompagnement",
      "applicant_designation" => "bénéficiaire du RSA",
      "rdv_subject" => "RSA",
      "display_mandatory_warning" => true,
      "punishable_warning" => "votre RSA pourra être suspendu ou réduit"
    },
    "rsa_accompagnement_sociopro" => {
      "model" => "standard",
      "rdv_title" => "rendez-vous d'accompagnement",
      "rdv_title_by_phone" => "rendez-vous d'accompagnement téléphonique",
      "rdv_purpose" => "démarrer un parcours d'accompagnement",
      "applicant_designation" => "bénéficiaire du RSA",
      "rdv_subject" => "RSA",
      "display_mandatory_warning" => true,
      "punishable_warning" => "votre RSA pourra être suspendu ou réduit"
    },
    "rsa_follow_up" => {
      "model" => "standard",
      "rdv_title" => "rendez-vous de suivi",
      "rdv_title_by_phone" => "rendez-vous de suivi téléphonique",
      "rdv_purpose" => "faire un point avec votre référent de parcours",
      "applicant_designation" => "bénéficiaire du RSA",
      "rdv_subject" => "RSA",
      "display_mandatory_warning" => false
    },
    "rsa_cer_signature" => {
      "model" => "standard",
      "rdv_title" => "rendez-vous de signature de CER",
      "rdv_title_by_phone" => "rendez-vous téléphonique de signature de CER",
      "rdv_purpose" => "construire et signer votre Contrat d'Engagement Réciproque",
      "applicant_designation" => "bénéficiaire du RSA",
      "rdv_subject" => "RSA",
      "display_mandatory_warning" => true
    },
    "rsa_main_tendue" => {
      "model" => "standard",
      "rdv_title" => "entretien de main tendue",
      "rdv_title_by_phone" => "entretien téléphonique de main tendue",
      "rdv_purpose" => "faire le point sur votre situation",
      "applicant_designation" => "bénéficiaire du RSA",
      "rdv_subject" => "RSA",
      "display_mandatory_warning" => true
    },
    "rsa_atelier_collectif_mandatory" => {
      "model" => "standard",
      "rdv_title" => "atelier collectif",
      "rdv_title_by_phone" => "atelier collectif",
      "rdv_purpose" => "vous aider dans votre parcours d'insertion",
      "applicant_designation" => "bénéficiaire du RSA",
      "rdv_subject" => "RSA",
      "display_mandatory_warning" => true
    },
    "rsa_spie" => {
      "model" => "standard",
      "rdv_title" => "rendez-vous d'accompagnement",
      "rdv_title_by_phone" => "rendez-vous d'accompagnement téléphonique",
      "rdv_purpose" => "démarrer un parcours d'accompagnement",
      "applicant_designation" => "demandeur d'emploi",
      "rdv_subject" => "demande d'emploi",
      "display_mandatory_warning" => true,
      "punishable_warning" => "votre RSA pourra être suspendu ou réduit"
    },
    "rsa_integration_information" => {
      "model" => "standard",
      "rdv_title" => "rendez-vous d'information",
      "rdv_title_by_phone" => "rendez-vous d'information téléphonique",
      "applicant_designation" => "bénéficiaire du RSA",
      "rdv_subject" => "RSA",
      "rdv_purpose" => "vous renseigner sur vos droits et vos devoirs",
      "display_mandatory_warning" => true
    },
    "rsa_insertion_offer" => {
      "model" => "atelier",
      "rdv_subject" => "RSA",
      "applicant_designation" => "bénéficiaire du RSA"
    },
    "rsa_atelier_competences" => {
      "model" => "atelier",
      "rdv_subject" => "RSA",
      "applicant_designation" => "bénéficiaire du RSA"
    },
    "rsa_atelier_rencontres_pro" => {
      "model" => "atelier",
      "rdv_subject" => "RSA",
      "applicant_designation" => "bénéficiaire du RSA"
    }
  }.freeze

  def change
    create_table :templates do |t|
      t.integer :model
      t.string :rdv_title
      t.string :rdv_title_by_phone
      t.string :rdv_purpose
      t.string :applicant_designation
      t.string :rdv_subject
      t.boolean :display_mandatory_warning
      t.boolean :display_punishable_warning

      t.timestamps
    end

    add_reference :motif_categories, :template, foreign_key: true

    up_only do
      TEMPLATE_ATTRIBUTES_BY_CATEGORY_SHORT_NAME.each do |category_short_name, template_attributes|
        motif_category = MotifCategory.find_by!(short_name: category_short_name)
        template = Template.find_or_create_by!(template_attributes)
        motif_category.update! template_id: template.id
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
