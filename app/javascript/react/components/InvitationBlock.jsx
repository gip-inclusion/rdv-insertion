import React, { useState } from "react";

import retrieveLastInvitationDate from "../../lib/retrieveLastInvitationDate";
import handleApplicantInvitation from "../lib/handleApplicantInvitation";
import getInvitationLetter from "../actions/getInvitationLetter";
import { getFrenchFormatDateString, todaysDateString } from "../../lib/datesHelper";

export default function InvitationBlock({
  applicant,
  invitations,
  organisation,
  department,
  context,
  isDepartmentLevel,
  invitationFormats,
  backgroundClassForStatus,
  status,
  statusText,
}) {
  const [isLoading, setIsLoading] = useState({
    smsInvitation: false,
    emailInvitation: false,
    postalInvitation: false,
  });
  const [lastSmsInvitationSentAt, setLastSmsInvitationSentAt] = useState(
    retrieveLastInvitationDate(invitations, "sms")
  );
  const [lastEmailInvitationSentAt, setLastEmailInvitationSentAt] = useState(
    retrieveLastInvitationDate(invitations, "email")
  );
  const [lastPostalInvitationSentAt, setLastPostalInvitationSentAt] = useState(
    retrieveLastInvitationDate(invitations, "postal")
  );
  const [currentStatusText, setCurrentStatusText] = useState(statusText);
  const [currentBackgroundClassForStatus, setCurrentBackgroundClassForStatus] =
    useState(backgroundClassForStatus);

  const showInvitation = (format) => invitationFormats.includes(format);

  const handleClick = async (action) => {
    setIsLoading({ ...isLoading, [action]: true });
    const applicantParams = [applicant, department.id, organisation, isDepartmentLevel, context];
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
    setCurrentStatusText("Invitation en attente de réponse");
    setCurrentBackgroundClassForStatus("");
    setIsLoading({ ...isLoading, [action]: false });
  };

  return (
    <div className="d-flex justify-content-center">
      <table className="tracking-block block-white text-center align-middle mb-4">
        <thead>
          <tr>
            <th className="px-4 py-3">
              <h4>Statut global</h4>
            </th>
            {showInvitation("sms") && (
              <th className="px-4 py-3">
                <h4>Invitation SMS</h4>
              </th>
            )}
            {showInvitation("email") && (
              <th className="px-4 py-3">
                <h4>Invitation mail</h4>
              </th>
            )}
            {showInvitation("postal") && (
              <th className="px-4 py-3">
                <h4>Invitation courrier</h4>
              </th>
            )}
          </tr>
        </thead>
        <tbody>
          <tr>
            <td className={`p-4 ${currentBackgroundClassForStatus}`} rowSpan="2">
              {currentStatusText}
            </td>
            {showInvitation("sms") && (
              <td className="px-4 py-3">
                {lastSmsInvitationSentAt ? getFrenchFormatDateString(lastSmsInvitationSentAt) : "-"}
              </td>
            )}
            {showInvitation("email") && (
              <td className="px-4 py-3">
                {lastEmailInvitationSentAt
                  ? getFrenchFormatDateString(lastEmailInvitationSentAt)
                  : "-"}
              </td>
            )}
            {showInvitation("postal") && (
              <td className="px-4 py-3">
                {lastPostalInvitationSentAt
                  ? getFrenchFormatDateString(lastPostalInvitationSentAt)
                  : "-"}
              </td>
            )}
          </tr>
          <tr>
            {showInvitation("sms") && (
              <td className="px-4 py-3">
                <button
                  type="button"
                  disabled={
                    isLoading.smsInvitation ||
                    !applicant.phone_number ||
                    applicant.is_archived === true ||
                    status === "rdv_pending"
                  }
                  className="btn btn-blue"
                  onClick={() => handleClick("smsInvitation")}
                >
                  {isLoading.smsInvitation && "Invitation..."}
                  {!isLoading.smsInvitation && lastSmsInvitationSentAt && "Relancer"}
                  {!isLoading.smsInvitation && !lastSmsInvitationSentAt && "Inviter"}
                </button>
              </td>
            )}
            {showInvitation("email") && (
              <td className="px-4 py-3">
                <button
                  type="button"
                  disabled={
                    isLoading.emailInvitation ||
                    !applicant.email ||
                    applicant.is_archived === true ||
                    status === "rdv_pending"
                  }
                  className="btn btn-blue"
                  onClick={() => handleClick("emailInvitation")}
                >
                  {isLoading.emailInvitation && "Invitation..."}
                  {!isLoading.emailInvitation && lastEmailInvitationSentAt && "Relancer"}
                  {!isLoading.emailInvitation && !lastEmailInvitationSentAt && "Inviter"}
                </button>
              </td>
            )}
            {showInvitation("postal") && (
              <td className="px-4 py-3">
                <button
                  type="button"
                  disabled={
                    isLoading.postalInvitation ||
                    !applicant.address ||
                    applicant.is_archived === true ||
                    status === "rdv_pending"
                  }
                  className="btn btn-blue"
                  onClick={() => handleClick("postalInvitation")}
                >
                  {isLoading.postalInvitation && "Invitation..."}
                  {!isLoading.postalInvitation && lastPostalInvitationSentAt && "Recréer"}
                  {!isLoading.postalInvitation && !lastPostalInvitationSentAt && "Inviter"}
                </button>
              </td>
            )}
          </tr>
        </tbody>
      </table>
    </div>
  );
}
