import React, { useState } from "react";

import retrieveLastInvitationDate from "../../lib/retrieveLastInvitationDate";
import handleApplicantInvitation from "../lib/handleApplicantInvitation";
import getInvitationLetter from "../actions/getInvitationLetter";
import { getFrenchFormatDateString, todaysDateString } from "../../lib/datesHelper";

export default function ApplicantTracker({
  applicant,
  organisation,
  department,
  isDepartmentLevel,
  showSmsInvitation,
  showEmailInvitation,
  showPostalInvitation,
  numberOfRdvs,
  numberOfCancelledRdvs,
  rdvToDisplay,
  statusNotice,
  outOfTime,
  actionRequired,
  humanStatus,
}) {
  const [isLoading, setIsLoading] = useState({
    smsInvitation: false,
    emailInvitation: false,
    postalInvitation: false,
  });
  const [isOutOfTime, setIsOutOfTime] = useState(outOfTime);
  const [hasActionRequired, setHasActionRequired] = useState(actionRequired);
  const showInvitations = showSmsInvitation || showEmailInvitation || showPostalInvitation;
  const [lastSmsInvitationSentAt, setLastSmsInvitationSentAt] = useState(
    retrieveLastInvitationDate(applicant.invitations, "sms")
  );
  const [lastEmailInvitationSentAt, setLastEmailInvitationSentAt] = useState(
    retrieveLastInvitationDate(applicant.invitations, "email")
  );
  const [lastPostalInvitationSentAt, setLastPostalInvitationSentAt] = useState(
    retrieveLastInvitationDate(applicant.invitations, "postal")
  );
  const [applicantStatus, setApplicantStatus] = useState(applicant.status);
  const [textForStatus, setTextForStatus] = useState(humanStatus);

  const bgColorClassForInvitationDate = (format) => {
    let lastInvitationDate = null;
    if (format === "sms") {
      lastInvitationDate = lastSmsInvitationSentAt;
    } else if (format === "email") {
      lastInvitationDate = lastEmailInvitationSentAt;
    } else {
      lastInvitationDate = lastPostalInvitationSentAt;
    }

    if (numberOfRdvs === 0 && applicant.is_archived === false) {
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

  const computeColSpanForInvitationBlock = () => {
    let colSpan = 0;
    if (showSmsInvitation) colSpan += 1;
    if (showEmailInvitation) colSpan += 1;
    if (showPostalInvitation) colSpan += 1;
    if (colSpan === 0) return "";
    return `col-${12 / colSpan}`;
  };

  const cssClassForInvitationDate = (format) => {
    const bgColorClass = bgColorClassForInvitationDate(format);
    if (bgColorClass.length === 0) {
      return `${computeColSpanForInvitationBlock()} py-2`;
    }
    return `${computeColSpanForInvitationBlock()} py-2 ${bgColorClass}`;
  };

  const computeColSpanForRdvBlock = () => (numberOfCancelledRdvs > 0 ? "col-3" : "col-4");

  const bgColorClassForApplicantStatus = () => {
    if (applicant.is_archived === true) {
      return "";
    }
    if (
      hasActionRequired &&
      (applicantStatus === "invitation_pending" || applicantStatus === "rdv_creation_pending")
    ) {
      return "text-dark-blue bg-warning border-warning";
    }
    if (hasActionRequired) {
      return "bg-danger border-danger";
    }
    if (applicantStatus === "rdv_seen") {
      return "bg-success border-success";
    }
    return "";
  };

  const cssClassForRdvsDates = () =>
    `${computeColSpanForRdvBlock()} d-flex align-items-center justify-content-center`;

  const cssClassForApplicantStatus = () => {
    const bgColorClass = bgColorClassForApplicantStatus();
    if (bgColorClass.length === 0) {
      return `${computeColSpanForRdvBlock()} d-flex align-items-center justify-content-center p-3`;
    }
    return `${computeColSpanForRdvBlock()} d-flex align-items-center justify-content-center p-3 ${bgColorClass}`;
  };

  const handleClick = async (action) => {
    setIsLoading({ ...isLoading, [action]: true });
    const applicantParams = [applicant, department.id, organisation, isDepartmentLevel];
    if (action === "smsInvitation") {
      const invitation = await handleApplicantInvitation(...applicantParams, "sms");
      setLastSmsInvitationSentAt(invitation?.sent_at);
    } else if (action === "emailInvitation") {
      const invitation = await handleApplicantInvitation(...applicantParams, "email");
      setLastEmailInvitationSentAt(invitation?.sent_at);
    } else {
      const invitationLetter = await getInvitationLetter(...applicantParams, "postal");
      if (invitationLetter?.success) {
        setLastPostalInvitationSentAt(todaysDateString());
      }
    }
    if (applicantStatus === "not_invited") {
      setApplicantStatus("invitation_pending");
      setTextForStatus("Invitation en attente de réponse");
    }
    setHasActionRequired(false);
    setIsOutOfTime(false);
    setIsLoading({ ...isLoading, [action]: false });
  };

  return (
    <div className="d-flex justify-content-around text-center flex-wrap mb-4 pb-3">
      {showInvitations && (
        <div className="tracking-block block-white">
          <div className="row d-flex justify-content-around">
            {showSmsInvitation && (
              <h4 className={computeColSpanForInvitationBlock()}>Invitation SMS</h4>
            )}
            {showEmailInvitation && (
              <h4 className={computeColSpanForInvitationBlock()}>Invitation mail</h4>
            )}
            {showPostalInvitation && (
              <h4 className={computeColSpanForInvitationBlock()}>Invitation courrier</h4>
            )}
          </div>
          <div className="row d-flex justify-content-around flex-nowrap">
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
            {showPostalInvitation && (
              <p className={cssClassForInvitationDate("postal")}>
                {lastPostalInvitationSentAt
                  ? getFrenchFormatDateString(lastPostalInvitationSentAt)
                  : "-"}
              </p>
            )}
          </div>
          <div className="row d-flex justify-content-around align-items-center">
            {showSmsInvitation && (
              <div className={computeColSpanForInvitationBlock()}>
                <button
                  type="button"
                  disabled={
                    isLoading.smsInvitation ||
                    numberOfRdvs > 0 ||
                    !applicant.phone_number ||
                    applicant.is_archived === true
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
              <div className={computeColSpanForInvitationBlock()}>
                <button
                  type="button"
                  disabled={
                    isLoading.emailInvitation ||
                    numberOfRdvs > 0 ||
                    !applicant.email ||
                    applicant.is_archived === true
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
            {showPostalInvitation && (
              <div className={computeColSpanForInvitationBlock()}>
                <button
                  type="button"
                  disabled={
                    isLoading.postalInvitation ||
                    numberOfRdvs > 0 ||
                    !applicant.address ||
                    applicant.is_archived === true
                  }
                  className="btn btn-blue"
                  onClick={() => handleClick("postalInvitation")}
                >
                  {isLoading.postalInvitation && "Invitation..."}
                  {!isLoading.postalInvitation && lastPostalInvitationSentAt && "Recréer"}
                  {!isLoading.postalInvitation && !lastPostalInvitationSentAt && "Inviter"}
                </button>
              </div>
            )}
          </div>
        </div>
      )}
      <div className="tracking-block block-2 block-white d-flex justify-content-center flex-column">
        <div className="row d-flex justify-content-around">
          <h4 className={computeColSpanForRdvBlock()}>RDV pris le</h4>
          <h4 className={computeColSpanForRdvBlock()}>Date du RDV</h4>
          {numberOfCancelledRdvs > 0 && (
            <h4 className="col-3">
              RDV reportés{" "}
              <small>
                <i className="fas fa-question-circle" id="js-rdv-cancelled-by-user-tooltip" />
              </small>
            </h4>
          )}
          <h4 className={computeColSpanForRdvBlock()}>Statut</h4>
        </div>
        <div className="row d-flex justify-content-around flex-grow-1">
          <div className={cssClassForRdvsDates()}>
            <p className="m-0">
              {numberOfRdvs > 0 ? getFrenchFormatDateString(rdvToDisplay.created_at) : "-"}
            </p>
          </div>
          <div className={cssClassForRdvsDates()}>
            <p className="m-0">
              {numberOfRdvs > 0 ? getFrenchFormatDateString(rdvToDisplay.starts_at) : "-"}
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
