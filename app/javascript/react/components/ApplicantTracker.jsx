import React, { useState } from "react";

import retrieveLastInvitationDate from "../../lib/retrieveLastInvitationDate";
import handleApplicantInvitation from "../lib/handleApplicantInvitation";
import { getFrenchFormatDateString } from "../../lib/datesHelper";

export default function ApplicantTracker({
  applicant,
  organisation,
  department,
  isDepartmentLevel,
  showSmsInvitation,
  showEmailInvitation,
  rdvs,
  numberOfCancelledRdvs,
  statusNotice,
  outOfTime,
  actionRequired,
  humanStatus,
}) {
  const [isLoading, setIsLoading] = useState({
    smsInvitation: false,
    emailInvitation: false,
  });
  const [isOutOfTime, setIsOutOfTime] = useState(outOfTime);
  const [hasActionRequired, setHasActionRequired] = useState(actionRequired);
  const [lastSmsInvitationSentAt, setLastSmsInvitationSentAt] = useState(
    retrieveLastInvitationDate(applicant.invitations, "sms")
  );
  const [lastEmailInvitationSentAt, setLastEmailInvitationSentAt] = useState(
    retrieveLastInvitationDate(applicant.invitations, "email")
  );
  const [applicantStatus, setApplicantStatus] = useState(applicant.status);
  const [textForStatus, setTextForStatus] = useState(humanStatus);

  const bgColorClassForInvitationDate = (format) => {
    let lastInvitationDate = null;
    if (format === "sms") {
      lastInvitationDate = lastSmsInvitationSentAt;
    } else if (format === "email") {
      lastInvitationDate = lastEmailInvitationSentAt;
    }

    if (rdvs.length === 0 && applicantStatus !== "resolved") {
      if (lastInvitationDate && isOutOfTime) {
        return "bg-warning";
      }
      if (lastInvitationDate) {
        return "bg-success";
      }
      if (!lastSmsInvitationSentAt && !lastEmailInvitationSentAt) {
        return "bg-danger";
      }
    }
    return "";
  };

  const cssClassForInvitationDate = (format) => {
    const bgColorClass = bgColorClassForInvitationDate(format);
    if (bgColorClass.length === 0) {
      return "col-4 py-2";
    }
    return `col-4 py-2 ${bgColorClass}`;
  };

  const numbersOfColumnsForRdvBlock = () => (numberOfCancelledRdvs > 0 ? "col-3" : "col-4");

  const bgColorClassForApplicantStatus = () => {
    if (
      hasActionRequired &&
      (applicantStatus === "invitation_pending" || applicantStatus === "rdv_creation_pending")
    ) {
      return "text-dark-blue bg-warning border-warning";
    }
    if (hasActionRequired) {
      return "bg-danger border-danger";
    }
    if (applicantStatus === "rdv_seen" || applicantStatus === "resolved") {
      return "bg-success border-success";
    }
    return "";
  };

  const cssClassForRdvsDates = () =>
    `${numbersOfColumnsForRdvBlock()} d-flex align-items-center justify-content-center`;

  const cssClassForApplicantStatus = () => {
    const bgColorClass = bgColorClassForApplicantStatus();
    if (bgColorClass.length === 0) {
      return `${numbersOfColumnsForRdvBlock()} d-flex align-items-center justify-content-center`;
    }
    return `${numbersOfColumnsForRdvBlock()} d-flex align-items-center justify-content-center ${bgColorClass}`;
  };

  const handleClick = async (action) => {
    setIsLoading({ ...isLoading, [action]: true });

    const format = action === "smsInvitation" ? "sms" : "email";
    const invitation = await handleApplicantInvitation(
      applicant.id,
      department.id,
      organisation,
      isDepartmentLevel,
      format
    );

    if (invitation?.sent_at) {
      if (format === "sms") {
        setLastSmsInvitationSentAt(invitation?.sent_at);
      } else {
        setLastEmailInvitationSentAt(invitation?.sent_at);
      }
      if (applicantStatus === "not_invited") {
        setApplicantStatus("invitation_pending");
        setTextForStatus("Invitation en attente de réponse");
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
          {showSmsInvitation && <h4 className="col-4">Invitation SMS</h4>}
          {showEmailInvitation && <h4 className="col-4">Invitation mail</h4>}
        </div>
        <div className="row d-flex justify-content-around flex-nowrap">
          <p className="col-4 py-2">{getFrenchFormatDateString(applicant.created_at)}</p>
          {showSmsInvitation && (
            <p className={cssClassForInvitationDate("sms")}>
              {lastSmsInvitationSentAt ? getFrenchFormatDateString(lastSmsInvitationSentAt) : "-"}
            </p>
          )}
          {showEmailInvitation && (
            <p className={cssClassForInvitationDate("email")}>
              {lastEmailInvitationSentAt
                ? getFrenchFormatDateString(lastEmailInvitationSentAt)
                : "-"}
            </p>
          )}
        </div>
        <div className="row d-flex justify-content-around align-items-center">
          <div className="col-4" />
          {showSmsInvitation && (
            <div className="col-4">
              <button
                type="button"
                disabled={
                  isLoading.smsInvitation ||
                  rdvs.length > 0 ||
                  !applicant.phone_number ||
                  applicantStatus === "resolved"
                }
                className="btn btn-blue"
                onClick={() => handleClick("smsInvitation")}
              >
                {isLoading.smsInvitation && "Invitation..."}
                {!isLoading.smsInvitation && lastSmsInvitationSentAt && "Relancer"}
                {!isLoading.smsInvitation && !lastSmsInvitationSentAt && "Inviter"}
              </button>
            </div>
          )}
          {showEmailInvitation && (
            <div className="col-4">
              <button
                type="button"
                disabled={
                  isLoading.emailInvitation ||
                  rdvs.length > 0 ||
                  !applicant.email ||
                  applicantStatus === "resolved"
                }
                className="btn btn-blue"
                onClick={() => handleClick("emailInvitation")}
              >
                {isLoading.emailInvitation && "Invitation..."}
                {!isLoading.emailInvitation && lastEmailInvitationSentAt && "Relancer"}
                {!isLoading.emailInvitation && !lastEmailInvitationSentAt && "Inviter"}
              </button>
            </div>
          )}
        </div>
      </div>
      <div className="tracking-block block-2 block-white d-flex justify-content-center flex-column">
        <div className="row d-flex justify-content-around">
          <h4 className={numbersOfColumnsForRdvBlock()}>RDV pris le</h4>
          <h4 className={numbersOfColumnsForRdvBlock()}>Date du RDV</h4>
          {numberOfCancelledRdvs > 0 && (
            <h4 className="col-3">
              RDV reportés{" "}
              <small>
                <i className="fas fa-question-circle" id="js-rdv-cancelled-by-user-tooltip" />
              </small>
            </h4>
          )}
          <h4 className={numbersOfColumnsForRdvBlock()}>Statut</h4>
        </div>
        <div className="row d-flex justify-content-around flex-grow-1">
          <div className={cssClassForRdvsDates()}>
            <p className="m-0">
              {rdvs.length > 0 ? getFrenchFormatDateString(rdvs.at(-1).created_at) : "-"}
            </p>
          </div>
          <div className={cssClassForRdvsDates()}>
            <p className="m-0">
              {rdvs.length > 0 ? getFrenchFormatDateString(rdvs.at(-1).starts_at) : "-"}
            </p>
          </div>
          {numberOfCancelledRdvs > 0 && (
            <div className="col-3 d-flex align-items-center justify-content-center">
              <p className="m-0">{numberOfCancelledRdvs}</p>
            </div>
          )}
          <div className={cssClassForApplicantStatus()}>
            <p className="m-0">
              {textForStatus}
              {statusNotice}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
