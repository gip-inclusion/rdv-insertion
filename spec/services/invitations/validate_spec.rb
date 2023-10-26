describe Invitations::Validate, type: :service do
  subject do
    described_class.call(
      invitation: invitation, rdv_solidarites_session: rdv_solidarites_session
    )
  end

  let!(:rdv_solidarites_session) { instance_double(RdvSolidaritesSession::Base) }
  let!(:category_orientation) do
    create(:motif_category, name: "RSA orientation", short_name: "rsa_orientation")
  end
  let!(:category_accompagnement) do
    create(:motif_category, name: "RSA accompagnement", short_name: "rsa_accompagnement")
  end

  let!(:invitation) do
    create(
      :invitation,
      user: user,
      rdv_context: build(:rdv_context, motif_category: category_orientation),
      organisations: [organisation]
    )
  end

  let!(:user) do
    create(:user, organisations: [organisation])
  end

  let!(:organisation) do
    create(:organisation, motifs: [motif])
  end

  let!(:configuration) do
    create(:configuration, organisation: organisation, motif_category: category_orientation)
  end

  let!(:motif) do
    create(:motif, motif_category: category_orientation)
  end

  let!(:department) do
    create(:department, organisations: [organisation], invitations: [invitation])
  end

  describe "#call" do
    before do
      allow(RdvSolidaritesApi::RetrieveCreneauAvailability).to receive(:call)
        .with(link_params: invitation.link_params, rdv_solidarites_session: rdv_solidarites_session)
        .and_return(OpenStruct.new(success?: true, creneau_availability: true))
    end

    it("is_a_success") do
      is_a_success
    end

    context "when organisations are from different departments" do
      before { organisation.department = build(:department) }

      it("is a failure") { is_a_failure }

      it "stores an error message" do
        expect(subject.errors).to include(
          "Les organisations ne peuvent pas être liés à des départements différents de l'invitation"
        )
      end
    end

    context "when the user title is missing" do
      before { user.update! title: nil }

      it("is a failure") { is_a_failure }

      it "stores an error message" do
        expect(subject.errors).to include(
          "La civilité de la personne doit être précisée pour pouvoir envoyer une invitation"
        )
      end
    end

    context "when it is a postal invitation and the validity is < 5 days" do
      before { invitation.assign_attributes(format: "postal", valid_until: 2.days.from_now) }

      it("is a failure") { is_a_failure }

      it "stores an error message" do
        expect(subject.errors).to include(
          "La durée de validité de l'invitation pour un courrier doit être supérieure à 5 jours"
        )
      end
    end

    context "when the user does not belong to an org for that category" do
      let!(:configuration) do
        create(:configuration, organisation: organisation, motif_category: category_accompagnement)
      end

      it("is a failure") { is_a_failure }

      it "stores an error message" do
        expect(subject.errors).to include(
          "L'usager n'appartient pas à une organisation qui gère la catégorie RSA orientation"
        )
      end
    end

    context "when there is no motif for that category on the organisations" do
      before { motif.update!(motif_category: category_accompagnement) }

      it("is a failure") { is_a_failure }

      it "stores an error message" do
        expect(subject.errors).to include(
          "Aucun motif de la catégorie RSA orientation n'est défini sur RDV-Solidarités"
        )
      end
    end

    context "with referents" do
      before do
        invitation.rdv_with_referents = true
      end

      let!(:motif) { create(:motif, motif_category: category_orientation, follow_up: true) }
      let!(:agent) { create(:agent, users: [user]) }

      it "is_a_success" do
        is_a_success
      end

      context "when no referents is assigned" do
        let!(:agent) { create(:agent, users: []) }

        it("is a failure") { is_a_failure }

        it "stores an error message" do
          expect(subject.errors).to include(
            "Un référent doit être assigné au bénéficiaire pour les rdvs avec référents"
          )
        end
      end

      context "when no follow up motifs are defined for the category" do
        let!(:motif) { create(:motif, motif_category: category_orientation, follow_up: false) }

        it("is a failure") { is_a_failure }

        it "stores an error message" do
          expect(subject.errors).to include(
            "Aucun motif de suivi n'a été défini pour la catégorie RSA orientation"
          )
        end
      end
    end

    context "when there are no creneau available on rdvs" do
      before do
        allow(RdvSolidaritesApi::RetrieveCreneauAvailability).to receive(:call)
          .with(link_params: invitation.link_params, rdv_solidarites_session: rdv_solidarites_session)
          .and_return(OpenStruct.new(success?: true, creneau_availability: false))
      end

      it("is a failure") { is_a_failure }

      it "stores an error message" do
        expect(subject.errors).to include(
          "L'envoi d'une invitation est impossible car il n'y a plus de créneaux disponibles. " \
          "Nous invitons donc à créer de nouvelles plages d'ouverture depuis l'interface " \
          "RDV-Solidarités pour pouvoir à nouveau envoyer des invitations"
        )
      end
    end
  end
end
