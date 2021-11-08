import React, { useState } from "react";

import retrieveLastInvitationDate from "../../lib/retrieveLastInvitationDate";
import handleApplicantInvitation from "../lib/handleApplicantInvitation"
import { getFrenchFormatDateString } from "../../lib/datesHelper"

export default function ApplicantTracker({
  applicant,
  organisation,
  rdvs,
  outOfTime,
  actionRequired
}) {
  const [isLoading, setIsLoading] = useState({
    smsInvitation: false,
    emailInvitation: false,
  });
  const [isOutOfTime, setIsOutOfTime] = useState(outOfTime);
  const [hasActionRequired, setHasActionRequired] = useState(actionRequired);
  const [lastSmsInvitationSentAt, setLastSmsInvitationSentAt] = useState(retrieveLastInvitationDate(applicant.invitations, "sms"));
  const [lastEmailInvitationSentAt, setLastEmailInvitationSentAt] = useState(retrieveLastInvitationDate(applicant.invitations, "email"));
  const [applicantStatus, setApplicantStatus] = useState(applicant.status);

  const baseCssClass = "col-4 d-flex align-items-center justify-content-center"

  const cssClassForInvitationDate = (format) => {
    let lastInvitationDate = null;
    if (format === "sms") {
      lastInvitationDate = lastSmsInvitationSentAt;
    } else if (format === "email") {
      lastInvitationDate = lastEmailInvitationSentAt;
    }

    if (rdvs.length === 0 && applicantStatus !== "resolved") {
      if (lastInvitationDate && isOutOfTime) {
        return " bg-warning";
      }
      if (lastInvitationDate) {
        return " bg-success";
      }
      if (!lastSmsInvitationSentAt && !lastEmailInvitationSentAt) {
        return " bg-danger";
      }
    }
    return ""
  }

  const cssClassForApplicantStatus = () => {
    if (hasActionRequired &&
      (applicantStatus === "invitation_pending" || applicantStatus === "rdv_creation_pending")) {
      return " text-dark-blue bg-warning border-warning"
    }
    if (hasActionRequired) {
      return " bg-danger border-danger"
    }
    if (applicantStatus === "rdv_seen" || applicantStatus === "resolved") {
      return " bg-success border-success"
    }
    return ""
  }

  const cssClassForApplicantRdv = () => {
    if (applicantStatus === "rdv_pending") {
      return " bg-success border-success"
    }
    return ""
  }

  const textForStatus = () => {
    // Changes in statuses wording also need to be echoed in applicant.fr.yml
    switch(applicantStatus) {
      case "not_invited":
        return "Non invité";
      case "invitation_pending":
        return "Invitation en attente de réponse";
      case "rdv_creation_pending":
        return "En attente de prise de RDV";
      case "rdv_pending":
        return "RDV pris";
      case "rdv_needs_status_update":
        return "Statut du RDV à préciser";
      case "rdv_noshow":
        return "Absence non excusée au RDV";
      case "rdv_revoked":
        return "RDV annulé à l'initative du Service";
      case "rdv_excused":
        return "RDV annulé à l'initiative de l'allocataire";
      case "rdv_seen":
        return "RDV honoré";
      case "resolved":
        return "Dossier clôturé";
      default:
        return "";
    }
  }

  const handleClick = async (action) => {
    setIsLoading({ ...isLoading, [action]: true });

    const format = (action === "smsInvitation") ? "sms" : "email";
    const invitation = await handleApplicantInvitation(organisation.id, applicant.id, format);

    if (invitation?.sent_at) {
      if (format === "sms") {
        setLastSmsInvitationSentAt(invitation?.sent_at)
      } else {
      setLastEmailInvitationSentAt(invitation?.sent_at)
      }
      if (applicantStatus === "not_invited") {
      setApplicantStatus("invitation_pending");
      }
      setHasActionRequired(false);
      setIsOutOfTime(false);
    }

    setIsLoading({ ...isLoading, [action]: false });
  };

  return (
    <div className="d-flex justify-content-around text-center flex-wrap mb-4 pb-3">
      <div className="tracking-block block-white">
        <div className="row d-flex justify-content-around">
          <h4 className="col-4">Création du compte</h4>
          <h4 className="col-4">Invitation SMS</h4>
          <h4 className="col-4">Invitation mail</h4>
        </div>
        <div className="row d-flex justify-content-around flex-nowrap">
          <p className="col-4 py-2">
            {getFrenchFormatDateString(applicant.created_at)}
          </p>
          <p className={`col-4 py-2${cssClassForInvitationDate("sms")}`}>
            {lastSmsInvitationSentAt ? getFrenchFormatDateString(lastSmsInvitationSentAt) : "-"}
          </p>
          <p className={`col-4 py-2${cssClassForInvitationDate("email")}`}>
            {lastEmailInvitationSentAt ? getFrenchFormatDateString(lastEmailInvitationSentAt) : "-"}
          </p>
        </div>
        <div className="row d-flex justify-content-around align-items-center">
          <div className="col-4" />
          <div className="col-4">
            <button
              type="button"
              disabled={isLoading.smsInvitation || (rdvs.length > 0 && !hasActionRequired) ||
                !applicant.phone_number_formatted || applicantStatus === "resolved"}
              className="btn btn-blue"
              onClick={() => handleClick("smsInvitation")}
            >
              {isLoading.smsInvitation && "Invitation..."}
              {!isLoading.smsInvitation && lastSmsInvitationSentAt && "Relancer"}
              {!isLoading.smsInvitation && !lastSmsInvitationSentAt && "Inviter"}
            </button>
          </div>
          <div className="col-4">
            <button
              type="button"
              disabled={isLoading.emailInvitation || (rdvs.length > 0 && !hasActionRequired) ||
                !applicant.email || applicantStatus === "resolved"}
              className="btn btn-blue"
              onClick={() => handleClick("emailInvitation")}
            >
              {isLoading.emailInvitation && "Invitation..."}
              {!isLoading.emailInvitation && lastEmailInvitationSentAt && "Relancer"}
              {!isLoading.emailInvitation && !lastEmailInvitationSentAt && "Inviter"}
            </button>
          </div>
        </div>
      </div>
      <div className="tracking-block block-2 block-white d-flex justify-content-center flex-column">
        <div className="row d-flex justify-content-around">
          <h4 className="col-4">RDV pris le</h4>
          <h4 className="col-4">Date du RDV</h4>
          <h4 className="col-4">Statut</h4>
        </div>
        <div className="row d-flex justify-content-around flex-grow-1">
          <div className={`${baseCssClass}${cssClassForApplicantRdv()}`}>
            <p>{rdvs.length > 0 ? getFrenchFormatDateString(rdvs.at(-1).created_at) : "-"}</p>
          </div>
          <div className={`${baseCssClass}${cssClassForApplicantRdv()}`}>
            <p>{rdvs.length > 0 ? getFrenchFormatDateString(rdvs.at(-1).starts_at) : "-"}</p>
          </div>
          <div className={`${baseCssClass}${cssClassForApplicantStatus()}`}>
            <p className="m-0">{textForStatus()}{isOutOfTime && applicantStatus === "invitation_pending" && " (Délai dépassé)"}</p>
          </div>
        </div>
      </div>
    </div>
  )
}
