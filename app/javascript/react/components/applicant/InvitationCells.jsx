import React from "react";
import Tippy from "@tippyjs/react";

import InvitationCell from "./InvitationCell";

export default function InvitationCells({
  applicant,
  invitationsColspan,
  isDepartmentLevel,
}) {
  return (
    /* ----------------------------- Disabled invitations cases -------------------------- */
    applicant.isArchivedInCurrentDepartment() ? (
      <td colSpan={invitationsColspan}>
        Dossier archivé
        {applicant.archiveInCurrentDepartment().archiving_reason && (
          <>&nbsp;: {applicant.archiveInCurrentDepartment().archiving_reason}</>
        )}
      </td>
    ) : applicant.createdAt && isDepartmentLevel && !applicant.linkedToCurrentCategory() ? (
      <td colSpan={invitationsColspan}>
        L'allocataire n'appartient pas à une organisation qui gère ce type de rdv{" "}
        <Tippy
          content={
            <>
              Ajoutez l'allocataire à une organisation qui gère ces rdvs en appuyant sur le boutton
              "Ajouter à une organisation" sur sa fiche, puis rechargez le fichier
            </>
          }
        >
          <i className="fas fa-question-circle" />
        </Tippy>
      </td>
    ) : applicant.currentContextStatus === "rdv_pending" ? (
      <>
        <td colSpan={invitationsColspan}>{applicant.currentRdvContext.human_status}</td>
      </>
    ) : (
      /* ----------------------------- Enabled invitations cases --------------------------- */

      <>
        {/* --------------------------------- Invitations ------------------------------- */}
        <InvitationCell
          applicant={applicant}
          format="sms"
        />
        <InvitationCell
          applicant={applicant}
          format="email"
        />
        <InvitationCell
          applicant={applicant}
          format="postal"
        />
      </>
    )
  );
}
