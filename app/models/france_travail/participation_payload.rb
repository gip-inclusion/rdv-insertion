module FranceTravail
  class ParticipationPayload
    def initialize(participation)
      @participation = participation
    end

    # rubocop:disable Metrics/AbcSize
    def to_h
      {
        id: @participation.france_travail_id,
        adresse: @participation.lieu&.address,
        date: @participation.starts_at.to_datetime,
        duree: @participation.duration_in_min,
        information: @participation.motif.instruction_for_rdv,
        initiateur: france_travail_initiateur,
        libelleAdresse: @participation.organisation.name,
        modaliteContact: france_travail_modalite,
        motif: france_travail_motif,
        organisme: {
          code: france_travail_organisme_code,
          emailContact: @participation.organisation.email,
          idStructure: @participation.organisation.safir_code,
          libelleStructure: @participation.organisation.name,
          telephoneContact: @participation.organisation.phone_number
        },
        statut: france_travail_statut,
        telephoneContactUsager: @participation.user.phone_number,
        theme: @participation.motif.name,
        typeReception: france_travail_type_reception,
        # agents.first est ok dans notre contexte ?
        interlocuteur: {
          email: @participation.agents.first.email,
          nom: @participation.agents.first.last_name,
          prenom: @participation.agents.first.first_name
        }
      }
    end
    # rubocop:enable Metrics/AbcSize

    # Liste des modalités FT (on ne prend en compte que le physique et le telephone): PHYSIQUE, TELEPHONE, VISIO
    def france_travail_modalite
      @participation.by_phone? ? "TELEPHONE" : "PHYSIQUE"
    end

    # Liste des initiateurs FT : USAGER, PARTENAIRE
    def france_travail_initiateur
      @participation.created_by_user? ? "USAGER" : "PARTENAIRE"
    end

    # Liste des motifs FT : AUT, ACC, ORI
    def france_travail_motif
      case @participation.motif.motif_category&.motif_category_type
      when "rsa_orientation"
        "ORI"
      when "rsa_accompagnement"
        "ACC"
      else
        "AUT"
      end
    end

    # Liste des codes organismes FT : IND, FT, CD, DCD, ML, CE
    def france_travail_organisme_code
      case @participation.organisation.organisation_type
      when "conseil_departemental"
        "CD"
      when "france_travail"
        "FT"
      when "delegataire_rsa"
        "DCD"
      else
        "IND"
      end
    end

    # Liste des types de réception FT : COL, IND
    def france_travail_type_reception
      @participation.collectif? ? "COL" : "IND"
    end

    # Liste des statuts FT : PRIS, EFFECTUE, MODIFIE, ABSENT, ANNULE
    def france_travail_statut
      case @participation.status
      when "seen"
        "EFFECTUE"
      when "excused", "revoked"
        "ANNULE"
      when "noshow"
        "ABSENT"
      else
        "PRIS"
      end
    end
  end
end
