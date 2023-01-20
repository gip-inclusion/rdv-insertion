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
    ) : applicant.isDuplicate ? (
      <Tippy
        content={
          <span>
            <strong>Cet allocataire est un doublon.</strong> Les doublons sont identifiés de 2
            façons&nbsp;:
            <br />
            1) Son numéro d&apos;ID éditeur est identique à un autre allocataire présent dans ce
            fichier.
            <br />
            2) Son numéro d&apos;allocataire <strong>et</strong> son rôle sont identiques à ceux
            d&apos;un autre allocataire présent dans ce fichier.
            <br />
            <br />
            Si cet allocataire a besoin d&apos;être créé, merci de modifier votre fichier et de le
            charger à nouveau.
          </span>
        }
      >
        <td colSpan={invitationsColspan}>
          <small className="d-inline-block mx-2">
            <i className="fas fa-exclamation-triangle" />
          </small>
        </td>
      </Tippy>
    ) : applicant.createdAt && isDepartmentLevel && !applicant.linkedToCurrentCategory() ? (
      <td colSpan={invitationsColspan}>
        L'allocataire n'appartient pas à une organisation qui gère ce type de rdv{" "}
        <Tippy
          content={
            <>
              Ajoutez l'allocataire à une organisation qui gère ces rdvs en appuyant sur le boutton
              "Ajouter à des organisations" sur sa fiche, puis rechargez le fichier
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
