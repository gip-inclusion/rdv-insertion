import React, { useState } from "react";

import retrieveLastInvitationDate from "../../lib/retrieveLastInvitationDate";
import handleApplicantInvitation from "../actions/handleApplicantInvitation"
import { getFrenchFormatDateString } from "../../lib/datesHelper"

export default function ApplicantTracker({
  applicant,
  organisation,
  rdvs,
  outOfTime,
  actionRequired,
  textForStatus
}) {
  const [isLoading, setIsLoading] = useState({
    smsInvitation: false,
    emailInvitation: false,
  });
  const [isOutOfTime, setIsOutOfTime] = useState(outOfTime);
  const [hasActionRequired, setHasActionRequired] = useState(actionRequired);
  const [lastSmsInvitationSentAt, setLastSmsInvitationSentAt] = useState(retrieveLastInvitationDate(applicant.invitations, "sms"));
  const [lastEmailInvitationSentAt, setLastEmailInvitationSentAt] = useState(retrieveLastInvitationDate(applicant.invitations, "email"));
  const [statusDisplayed, setStatusDisplayed] = useState(textForStatus);

  const classForInvitationDate = (format) => {
    let date = null;
    if (format === "sms") {
      date = lastSmsInvitationSentAt;
    } else if (format === "email") {
      date = lastEmailInvitationSentAt;
    }

    if (date && isOutOfTime) {
      return "col-4 py-2 bg-warning";
    }
    if (date && rdvs.length === 0) {
      return "col-4 py-2 bg-success";
    }
    if (!lastSmsInvitationSentAt && !lastEmailInvitationSentAt) {
      return "col-4 py-2 bg-danger";
    }
    return "col-4 py-2";
  }

  const classForApplicantStatus = () => {
    const baseClass = "col-4 d-flex align-items-center justify-content-center"

    if (hasActionRequired &&
      (applicant.status === "invitation_pending" || applicant.status === "rdv_creation_pending")) {
      return `${baseClass} text-dark-blue bg-warning border-warning`
    }
    if (hasActionRequired) {
      return `${baseClass} bg-danger border-danger`
    }
    if (applicant.status === "rdv_seen") {
      return `${baseClass} text-white bg-success border-success`
    }
    return baseClass
  }

  const classForApplicantRdv = () => {
    const baseClass = "col-4 d-flex align-items-center justify-content-center"

    if (applicant.status === "rdv_pending" || applicant.status === "rdv_seen") {
      return `${baseClass} text-white bg-success border-success`
    }
    if (applicant.status === "rdv_revoked" || applicant.status === "rdv_excused") {
      return `${baseClass} text-dark-blue bg-warning border-warning`
    }
    if (applicant.status === "rdv_noshow") {
      return `${baseClass} bg-danger border-danger`
    }
    return baseClass
  }

  const handleClick = async (action) => {
    setIsLoading({ ...isLoading, [action]: true });
    let format;
    // eslint-disable-next-line no-unused-expressions
    (action === "smsInvitation") ? format = "sms" : format = "email"
    const invitation = await handleApplicantInvitation(organisation.id, applicant.id, format);

    if (invitation?.sent_at) {
      if (format === "sms") {
        setLastSmsInvitationSentAt(invitation?.sent_at)
      } else {
      setLastEmailInvitationSentAt(invitation?.sent_at)
      }
      if (statusDisplayed === "Non invité") {
      setStatusDisplayed("Invitation en attente de réponse");
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
          <p className={classForInvitationDate("sms")}>
            {lastSmsInvitationSentAt ? getFrenchFormatDateString(lastSmsInvitationSentAt) : "-"}
          </p>
          <p className={classForInvitationDate("email")}>
            {lastEmailInvitationSentAt ? getFrenchFormatDateString(lastEmailInvitationSentAt) : "-"}
          </p>
        </div>
        <div className="row d-flex justify-content-around align-items-center">
          <div className="col-4" />
          <div className="col-4">
            <button
              type="button"
              disabled={isLoading.smsInvitation || (rdvs.length > 0 && !hasActionRequired) || !applicant.phone_number_formatted}
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
              disabled={isLoading.emailInvitation || (rdvs.length > 0 && !hasActionRequired) || !applicant.email}
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
          <div className={classForApplicantRdv()}>
            <p>{rdvs.length > 0 ? getFrenchFormatDateString(rdvs.at(-1).created_at) : "-"}</p>
          </div>
          <div className={classForApplicantRdv()}>
            <p>{rdvs.length > 0 ? getFrenchFormatDateString(rdvs.at(-1).starts_at) : "-"}</p>
          </div>
          <div className={classForApplicantStatus()}>
            <p className="m-0">{statusDisplayed}{isOutOfTime && " (Délai dépassé)"}</p>
          </div>
        </div>
      </div>
    </div>
  )
}
