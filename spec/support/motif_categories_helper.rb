# rubocop:disable Metrics/ModuleLength
module MotifCategoriesHelper
  shared_context "with all existing categories" do
    let!(:category_rsa_orientation) do
      create(
        :motif_category,
        name: "RSA orientation", short_name: "rsa_orientation",
        template: create(
          :template,
          model: "standard",
          rdv_title: "rendez-vous d'orientation",
          rdv_title_by_phone: "rendez-vous d'orientation téléphonique",
          rdv_purpose: "démarrer un parcours d'accompagnement",
          applicant_designation: "bénéficiaire du RSA",
          rdv_subject: "RSA",
          display_mandatory_warning: true,
          display_punishable_warning: false
        )
      )
    end
    let!(:category_rsa_accompagnement) do
      create(
        :motif_category,
        name: "RSA accompagnement",
        short_name: "rsa_accompagnement",
        template: create(
          :template,
          model: "standard",
          rdv_title: "rendez-vous d'accompagnement",
          rdv_title_by_phone: "rendez-vous d'accompagnement téléphonique",
          rdv_purpose: "démarrer un parcours d'accompagnement",
          applicant_designation: "bénéficiaire du RSA",
          rdv_subject: "RSA",
          display_mandatory_warning: true,
          display_punishable_warning: true
        )
      )
    end
    let!(:category_rsa_accompagnement_sociopro) do
      create(
        :motif_category,
        name: "RSA accompagnement socio-pro",
        short_name: "rsa_accompagnement_sociopro",
        template: create(
          :template,
          model: "standard",
          rdv_title: "rendez-vous d'accompagnement",
          rdv_title_by_phone: "rendez-vous d'accompagnement téléphonique",
          rdv_purpose: "démarrer un parcours d'accompagnement",
          applicant_designation: "bénéficiaire du RSA",
          rdv_subject: "RSA",
          display_mandatory_warning: true,
          display_punishable_warning: true
        )
      )
    end
    let!(:category_rsa_accompagnement_social) do
      create(
        :motif_category,
        name: "RSA accompagnement social",
        short_name: "rsa_accompagnement_social",
        template: create(
          :template,
          model: "standard",
          rdv_title: "rendez-vous d'accompagnement",
          rdv_title_by_phone: "rendez-vous d'accompagnement téléphonique",
          rdv_purpose: "démarrer un parcours d'accompagnement",
          applicant_designation: "bénéficiaire du RSA",
          rdv_subject: "RSA",
          display_mandatory_warning: true,
          display_punishable_warning: true
        )
      )
    end
    let!(:category_rsa_cer_signature) do
      create(
        :motif_category,
        name: "RSA signature CER",
        short_name: "rsa_cer_signature",
        template: create(
          :template,
          model: "standard",
          rdv_title: "rendez-vous de signature de CER",
          rdv_title_by_phone: "rendez-vous téléphonique de signature de CER",
          rdv_purpose: "construire et signer votre Contrat d'Engagement Réciproque",
          applicant_designation: "bénéficiaire du RSA",
          rdv_subject: "RSA",
          display_mandatory_warning: true,
          display_punishable_warning: false
        )
      )
    end
    let!(:category_rsa_follow_up) do
      create(
        :motif_category,
        name: "RSA suivi",
        short_name: "rsa_follow_up",
        template: create(
          :template,
          model: "standard",
          rdv_title: "rendez-vous de suivi",
          rdv_title_by_phone: "rendez-vous de suivi téléphonique",
          rdv_purpose: "faire un point avec votre référent de parcours",
          applicant_designation: "bénéficiaire du RSA",
          rdv_subject: "RSA",
          display_mandatory_warning: false,
          display_punishable_warning: false
        )
      )
    end
    let!(:category_rsa_insertion_offer) do
      create(
        :motif_category,
        name: "RSA offre insertion pro",
        short_name: "rsa_insertion_offer",
        participation_optional: true,
        template: create(
          :template,
          model: "atelier",
          rdv_subject: "RSA",
          applicant_designation: "bénéficiaire du RSA"
        )
      )
    end
    let!(:category_rsa_orientation_on_phone_platform) do
      create(
        :motif_category,
        name: "RSA orientation sur plateforme téléphonique",
        short_name: "rsa_orientation_on_phone_platform",
        template: create(
          :template,
          model: "phone_platform",
          rdv_title: "rendez-vous d'orientation téléphonique",
          rdv_subject: "RSA",
          applicant_designation: "bénéficiaire du RSA",
          rdv_purpose: "démarrer un parcours d'accompagnement"
        )
      )
    end
    let!(:category_rsa_atelier_collectif_mandatory) do
      create(
        :motif_category,
        name: "RSA Atelier collectif obligatoire",
        short_name: "rsa_atelier_collectif_mandatory",
        template: create(
          :template,
          model: "standard",
          rdv_title: "atelier collectif",
          rdv_title_by_phone: "atelier collectif",
          rdv_purpose: "vous aider dans votre parcours d'insertion",
          applicant_designation: "bénéficiaire du RSA",
          rdv_subject: "RSA",
          display_mandatory_warning: true,
          display_punishable_warning: false
        )
      )
    end
    let!(:category_rsa_atelier_rencontres_pro) do
      create(
        :motif_category,
        name: "RSA Atelier rencontres professionnelles",
        short_name: "rsa_atelier_rencontres_pro",
        participation_optional: true,
        template: create(
          :template,
          model: "atelier",
          rdv_subject: "RSA",
          applicant_designation: "bénéficiaire du RSA"
        )
      )
    end
    let!(:category_rsa_atelier_competences) do
      create(
        :motif_category,
        name: "RSA Atelier compétences",
        short_name: "rsa_atelier_competences",
        participation_optional: true,
        template: create(
          :template,
          model: "atelier",
          rdv_subject: "RSA",
          applicant_designation: "bénéficiaire du RSA"
        )
      )
    end
    let!(:category_rsa_main_tendue) do
      create(
        :motif_category,
        name: "RSA Main Tendue",
        short_name: "rsa_main_tendue",
        template: create(
          :template,
          model: "standard",
          rdv_title: "entretien de main tendue",
          rdv_title_by_phone: "entretien téléphonique de main tendue",
          rdv_purpose: "faire le point sur votre situation",
          applicant_designation: "bénéficiaire du RSA",
          rdv_subject: "RSA",
          display_mandatory_warning: true,
          display_punishable_warning: false
        )
      )
    end
    let!(:category_rsa_spie) do
      create(
        :motif_category,
        name: "RSA SPIE",
        short_name: "rsa_spie",
        template: create(
          :template,
          model: "standard",
          rdv_title: "rendez-vous d'accompagnement",
          rdv_title_by_phone: "rendez-vous d'accompagnement téléphonique",
          rdv_purpose: "démarrer un parcours d'accompagnement",
          applicant_designation: "demandeur d'emploi",
          rdv_subject: "demande d'emploi",
          display_mandatory_warning: true,
          display_punishable_warning: true
        )
      )
    end
    let!(:category_rsa_integration_information) do
      create(
        :motif_category,
        name: "RSA Information d'intégration",
        short_name: "rsa_integration_information",
        template: create(
          :template,
          model: "standard",
          rdv_title: "rendez-vous d'information",
          rdv_title_by_phone: "rendez-vous d'information téléphonique",
          applicant_designation: "bénéficiaire du RSA",
          rdv_subject: "RSA",
          rdv_purpose: "vous renseigner sur vos droits et vos devoirs",
          display_mandatory_warning: true,
          display_punishable_warning: false
        )
      )
    end
    let!(:category_psychologue) do
      create(
        :motif_category,
        name: "Psychologue",
        short_name: "psychologue",
        template: create(
          :template,
          model: "short",
          rdv_title: "rendez-vous de suivi psychologue",
          display_mandatory_warning: false,
          display_punishable_warning: false
        )
      )
    end
  end
end
# rubocop:enable Metrics/ModuleLength
