import React from "react";
import Tippy from "@tippyjs/react";

import handleApplicantCreation from "../../lib/handleApplicantCreation";
import handleArchivingDelete from "../../lib/handleArchivingDelete";
import retrieveRelevantOrganisation from "../../../lib/retrieveRelevantOrganisation";

import { getFrenchFormatDateString } from "../../../lib/datesHelper";

export default function CreationCell({
  applicant,
  isDepartmentLevel,
  isTriggered,
  setIsTriggered,
}) {
  const handleFileReopen = async () => {
    setIsTriggered({ ...isTriggered, unarchiving: true });

    await handleArchivingDelete(applicant);

    setIsTriggered({ ...isTriggered, unarchiving: false });
  };

  const handleCreationClick = async () => {
    setIsTriggered({ ...isTriggered, creation: true });

    if (!applicant.currentOrganisation) {
      applicant.currentOrganisation = await retrieveRelevantOrganisation(
        applicant.departmentNumber,
        applicant.linkedOrganisationSearchTerms,
        applicant.fullAddress
      );

      // If there is still no organisation it means the assignation was cancelled by agent
      if (!applicant.currentOrganisation) {
        setIsTriggered({ ...isTriggered, creation: false });
        return;
      }
    }
    await handleApplicantCreation(applicant, applicant.currentOrganisation.id);

    setIsTriggered({ ...isTriggered, creation: false });
  };

  return applicant.isArchivedInCurrentDepartment() ? (
    <td>
      <button
        type="submit"
        disabled={isTriggered.unarchiving}
        className="btn btn-primary btn-blue"
        onClick={() => handleFileReopen()}
      >
        Rouvrir le dossier
      </button>
    </td>
  ) : applicant.createdAt ? (
    !applicant.belongsToCurrentOrg() ? (
      <Tippy
        content={
          <span>
            Cet allocataire est déjà présent dans RDV-Insertion dans une autre organisation que
            l&apos;organisation actuelle.
            <br />
            Appuyez sur ce bouton pour ajouter l&apos;allocataire à cette organisation et mettre à
            jours ses informations.
          </span>
        }
      >
        <td>
          <button
            type="submit"
            disabled={isTriggered.creation}
            className="btn btn-primary btn-blue"
            onClick={() => handleCreationClick()}
          >
            {isTriggered.creation ? "En cours..." : "Ajouter à cette organisation"}
          </button>
        </td>
      </Tippy>
    ) : (
      <td>
        <a
          href={
            isDepartmentLevel
              ? `/departments/${applicant.department.id}/applicants/${applicant.id}`
              : `/organisations/${applicant.currentOrganisation.id}/applicants/${applicant.id}`
          }
          target="_blank"
          rel="noreferrer"
        >
          <Tippy
            content={
              <span>
                Compte créé le&nbsp;
                {getFrenchFormatDateString(applicant.createdAt)}
                <br />
                Vous pouvez consulter sa fiche en cliquant
              </span>
            }
          >
            <i className="fas fa-link" />
          </Tippy>
        </a>
      </td>
    )
  ) : applicant.isDuplicate ? (
    <td>
      <button type="submit" disabled className="btn btn-primary btn-blue">
        Création impossible
      </button>
    </td>
  ) : (
    <td>
      <button
        type="submit"
        disabled={isTriggered.creation}
        className="btn btn-primary btn-blue"
        onClick={() => handleCreationClick()}
      >
        {isTriggered.creation ? "Création..." : "Créer compte"}
      </button>
    </td>
  );
}
