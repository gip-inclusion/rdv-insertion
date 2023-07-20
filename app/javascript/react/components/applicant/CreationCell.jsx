import React from "react";
import { observer } from "mobx-react-lite";
import Tippy from "@tippyjs/react";

import Applicants from "../../models/Applicants";

import handleApplicantCreation from "../../lib/handleApplicantCreation";
import handleArchiveDelete from "../../lib/handleArchiveDelete";
import retrieveRelevantOrganisation from "../../../lib/retrieveRelevantOrganisation";

import { getFrenchFormatDateString } from "../../../lib/datesHelper";

export default observer(({
  applicant,
  isDepartmentLevel,
}) => {
  const handleFileReopen = async () => {
    applicant.triggers.unarchive = true;

    await handleArchiveDelete(applicant);

    applicant.triggers.unarchive = false;
  };

  const handleCreationClick = async () => {
    let elements = [applicant]

    if (Applicants.selectedApplicants.length > 1 && applicant.selected && confirm("Cette action va être appliquée à tous les éléments sélectionnés. Êtes-vous sûr ?")) {
      elements = Applicants.selectedApplicants
    }

      
    for (const element of elements) {
      element.triggers.creation = true;

      if (!element.currentOrganisation) {
        // eslint-disable-next-line no-await-in-loop
        element.currentOrganisation = await retrieveRelevantOrganisation(
          element.departmentNumber,
          element.linkedOrganisationSearchTerms,
          element.fullAddress
        );

        // If there is still no organisation it means the assignation was cancelled by agent
        if (!element.currentOrganisation) {
          element.triggers.creation = false;
          return;
        }
      }
      // eslint-disable-next-line no-await-in-loop
      await handleApplicantCreation(element, element.currentOrganisation.id);

      element.triggers.creation = false;
    }
  };

  return applicant.isArchivedInCurrentDepartment() ? (
    <td>
      <button
        type="submit"
        disabled={applicant.triggers.unarchive}
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
            disabled={applicant.triggers.creation}
            className="btn btn-primary btn-blue"
            onClick={() => handleCreationClick()}
          >
            {applicant.triggers.creation ? "En cours..." : "Ajouter à cette organisation"}
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
  ) : (
    <td>
      <button
        type="submit"
        disabled={applicant.triggers.creation}
        className="btn btn-primary btn-blue"
        onClick={() => handleCreationClick()}
      >
        {applicant.triggers.creation ? "Création..." : "Créer compte"}
      </button>
    </td>
  );
});
