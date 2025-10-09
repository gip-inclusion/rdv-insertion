module Participation::FranceTravailPayload
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/AbcSize
  def to_ft_payload
    {
      id: france_travail_id,
      adresse: address,
      date: starts_at.to_datetime,
      duree: duration_in_min,
      information: motif.instruction_for_rdv,
      initiateur: france_travail_initiateur,
      libelleAdresse: organisation.name,
      modaliteContact: france_travail_modalite,
      motif: france_travail_motif,
      organisme: {
        code: france_travail_organisme_code,
        emailContact: organisation.email,
        idStructure: organisation.safir_code,
        libelleStructure: organisation.name,
        telephoneContact: organisation.phone_number
      },
      statut: france_travail_statut,
      telephoneContactUsager: user.phone_number,
      theme: motif.name,
      typeReception: france_travail_type_reception,
      interlocuteur: {
        email: agents.first&.email,
        nom: agents.first&.last_name,
        prenom: agents.first&.first_name
      }
    }
  end
  # rubocop:enable Metrics/AbcSize

  private

  # Liste des modalités FT (on ne prend en compte que le physique et le telephone): PHYSIQUE, TELEPHONE, VISIO
  def france_travail_modalite
    by_phone? ? "TELEPHONE" : "PHYSIQUE"
  end

  # Liste des initiateurs FT : USAGER, PARTENAIRE, PRESCRIPTEUR
  def france_travail_initiateur
    created_by_user? ? "USAGER" : "PARTENAIRE"
    created_by_prescripteur? ? "PRESCRIPTEUR" : "PARTENAIRE"
  end

  # Liste des motifs FT : AUT, ACC, ORI
  def france_travail_motif
    case motif.motif_category&.motif_category_type
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
    case organisation.organisation_type
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
    collectif? ? "COL" : "IND"
  end

  # Liste des statuts FT : PRIS, EFFECTUE, MODIFIE, ABSENT, ANNULE
  def france_travail_statut
    case status
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
