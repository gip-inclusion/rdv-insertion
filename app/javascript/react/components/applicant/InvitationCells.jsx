import React from "react";
import Tippy from "@tippyjs/react";

import InvitationCell from "./InvitationCell";

export default function InvitationCells({
  applicant,
  invitationsColspan,
  isDepartmentLevel,
  isTriggered,
  setIsTriggered,
}) {
  return (
    /* ----------------------------- Disabled invitations cases -------------------------- */
    applicant.isArchived ? (
      <td colSpan={invitationsColspan}>
        Dossier archivé
        {applicant.archiving_reason && <>&nbsp;: {applicant.archiving_reason}</>}
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
          isTriggered={isTriggered}
          setIsTriggered={setIsTriggered}
          isDepartmentLevel={isDepartmentLevel}
          format="sms"
        />
        <InvitationCell
          applicant={applicant}
          isTriggered={isTriggered}
          setIsTriggered={setIsTriggered}
          isDepartmentLevel={isDepartmentLevel}
          format="email"
        />
        <InvitationCell
          applicant={applicant}
          isTriggered={isTriggered}
          setIsTriggered={setIsTriggered}
          isDepartmentLevel={isDepartmentLevel}
          format="postal"
        />
      </>
    )
  );
}
