module MotifCategoriesHelper
  shared_context "with all existing categories" do
    let!(:category_rsa_orientation) do
      create(:motif_category, name: "RSA orientation", short_name: "rsa_orientation")
    end
    let!(:category_rsa_accompagnement) do
      create(:motif_category, name: "RSA accompagnement", short_name: "rsa_accompagnement")
    end
    let!(:category_rsa_accompagnement_sociopro) do
      create(:motif_category, name: "RSA accompagnement socio-pro", short_name: "rsa_accompagnement_sociopro")
    end
    let!(:category_rsa_accompagnement_social) do
      create(:motif_category, name: "RSA accompagnement social", short_name: "rsa_accompagnement_social")
    end
    let!(:category_rsa_cer_signature) do
      create(:motif_category, name: "RSA signature CER", short_name: "rsa_cer_signature")
    end
    let!(:category_rsa_follow_up) do
      create(:motif_category, name: "RSA suivi", short_name: "rsa_follow_up")
    end
    let!(:category_rsa_insertion_offer) do
      create(:motif_category, name: "RSA offre insertion pro", short_name: "rsa_insertion_offer")
    end
    let!(:category_rsa_orientation_on_phone_platform) do
      create(
        :motif_category,
        name: "RSA orientation sur plateforme téléphonique", short_name: "rsa_orientation_on_phone_platform"
      )
    end
    let!(:category_rsa_atelier_collectif_mandatory) do
      create(:motif_category, name: "RSA Atelier collectif obligatoire", short_name: "rsa_atelier_collectif_mandatory")
    end
    let!(:category_rsa_atelier_rencontres_pro) do
      create(:motif_category, name: "RSA Atelier rencontres professionnelles", short_name: "rsa_atelier_rencontres_pro")
    end
    let!(:category_rsa_atelier_competences) do
      create(:motif_category, name: "RSA Atelier compétences", short_name: "rsa_atelier_competences")
    end
    let!(:category_rsa_main_tendue) do
      create(:motif_category, name: "RSA Main Tendue", short_name: "rsa_main_tendue")
    end
    let!(:category_rsa_spie) do
      create(:motif_category, name: "RSA SPIE", short_name: "rsa_spie")
    end
    let!(:category_rsa_integration_information) do
      create(:motif_category, name: "RSA Information d'intégration", short_name: "rsa_integration_information")
    end
  end
end
