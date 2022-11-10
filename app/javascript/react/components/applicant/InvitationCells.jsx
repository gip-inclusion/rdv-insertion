import React, { useState } from "react";
import Swal from "sweetalert2";
import Tippy from "@tippyjs/react";

import { getFrenchFormatDateString } from "../../../lib/datesHelper";

import SmsInvitationCell from "./SmsInvitationCell";
import EmailInvitationCell from "./EmailInvitationCell";
import PostalInvitationCell from "./PostalInvitationCell";

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
    ) : applicant.createdAt && !applicant.currentRdvContext && isDepartmentLevel ? (
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
        <Tippy
          content={
            <span>
              <>Un rdv est en attente pour ce bénéficiaire</>
            </span>
          }
        >
          <td colSpan={invitationsColspan}>
            {applicant.currentRdvContext.human_status}&nbsp;
            <i className="fas fa-question-circle" />
          </td>
        </Tippy>
      </>
    ) : (
      /* ----------------------------- Enabled invitations cases --------------------------- */

      <>
        {/* --------------------------------- Invitations ------------------------------- */}
        <SmsInvitationCell
          applicant={applicant}
          isTriggered={isTriggered}
          setIsTriggered={setIsTriggered}
          isDepartmentLevel={isDepartmentLevel}
        />
        <EmailInvitationCell
          applicant={applicant}
          isTriggered={isTriggered}
          setIsTriggered={setIsTriggered}
          isDepartmentLevel={isDepartmentLevel}
        />
        <PostalInvitationCell
          applicant={applicant}
          isTriggered={isTriggered}
          setIsTriggered={setIsTriggered}
          isDepartmentLevel={isDepartmentLevel}
        />
      </>
    )
  );
}
