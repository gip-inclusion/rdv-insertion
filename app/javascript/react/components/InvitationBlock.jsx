import React, { useState } from "react";
import InvitationsDatesRow from "./InvitationsDatesRow";

import sortInvitationsByFormatsAndDates from "../../lib/sortInvitationsByFormatsAndDates";
import handleApplicantInvitation from "../lib/handleApplicantInvitation";
import getInvitationLetter from "../actions/getInvitationLetter";
import { todaysDateString } from "../../lib/datesHelper";

export default function InvitationBlock({
  applicant,
  invitations,
  organisation,
  department,
  context,
  isDepartmentLevel,
  invitationFormats,
  numberOfDaysToAcceptInvitation,
  status,
}) {
  const [isLoading, setIsLoading] = useState({
    sms: false,
    email: false,
    postal: false,
  });
  /* eslint no-unused-vars: ["error", { "varsIgnorePattern": "setInvitationsDatesByFormat" }] */
  // This state is updated by .unshift in handleInvitationClick method
  const [invitationsDatesByFormat, setInvitationsDatesByFormat] = useState(
    sortInvitationsByFormatsAndDates(invitations)
  );
  const [showInvitationsHistory, setShowInvitationsHistory] = useState(false);

  // We don't display "Show history" button if there is no history to display
  const showInvitationsHistoryButton = Object.values(invitationsDatesByFormat).some(
    (array) => array.length > 1
  );

  const computeInvitationsDatesRows = () => {
    const numberOfInvitationsDatesRowsNeeded = Object.values(invitationsDatesByFormat).reduce(
      (r, s) => (r > s.length ? r : s.length),
      0
    );
    const invitationsDatesRowsArray = [];
    for (let i = 0; i < numberOfInvitationsDatesRowsNeeded; i += 1) {
      invitationsDatesRowsArray.push(i);
    }
    return invitationsDatesRowsArray;
  };

  const updateStatusBlock = () => {
    const statusBlock = document.getElementById(`js-block-status-${context}`);
    if (statusBlock) {
      statusBlock.textContent = "Invitation en attente de réponse";
      statusBlock.className = "p-4";
    }
  };

  const showInvitation = (format) => invitationFormats.includes(format);

  const handleInvitationClick = async (format) => {
    setIsLoading({ ...isLoading, [format]: true });
    const applicantParams = [
      applicant,
      department.id,
      organisation,
      isDepartmentLevel,
      context,
      numberOfDaysToAcceptInvitation,
    ];
    let newInvitationDate;

    if (format === "postal") {
      const invitationLetter = await getInvitationLetter(...applicantParams, format);
      if (invitationLetter?.success) {
        newInvitationDate = todaysDateString();
      }
    } else {
      const invitation = await handleApplicantInvitation(...applicantParams, format);
      newInvitationDate = invitation?.sent_at;
    }
    invitationsDatesByFormat[format].unshift(newInvitationDate);
    updateStatusBlock();
    setIsLoading({ ...isLoading, [format]: false });
  };

  return (
    <div className="d-flex justify-content-center">
      <table className="block-white text-center align-middle mb-4 mx-4">
        <thead>
          <tr>
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
          {!showInvitationsHistory && (
            <InvitationsDatesRow
              invitationsDatesByFormat={invitationsDatesByFormat}
              invitationFormats={invitationFormats}
              index={0}
              key={`${context}${0}`}
            />
          )}
          {showInvitationsHistory &&
            computeInvitationsDatesRows().map((index) => (
              <InvitationsDatesRow
                invitationsDatesByFormat={invitationsDatesByFormat}
                invitationFormats={invitationFormats}
                index={index}
                key={`${context}${index}`}
              />
            ))}
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
                  onClick={() => handleInvitationClick("sms")}
                >
                  {isLoading.smsInvitation && "Invitation..."}
                  {!isLoading.smsInvitation && invitationsDatesByFormat.sms[0] && "Relancer"}
                  {!isLoading.smsInvitation && !invitationsDatesByFormat.sms[0] && "Inviter"}
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
                  onClick={() => handleInvitationClick("email")}
                >
                  {isLoading.emailInvitation && "Invitation..."}
                  {!isLoading.emailInvitation && invitationsDatesByFormat.email[0] && "Relancer"}
                  {!isLoading.emailInvitation && !invitationsDatesByFormat.email[0] && "Inviter"}
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
                  onClick={() => handleInvitationClick("postal")}
                >
                  {isLoading.postalInvitation && "Invitation..."}
                  {!isLoading.postalInvitation && invitationsDatesByFormat.postal[0] && "Recréer"}
                  {!isLoading.postalInvitation && !invitationsDatesByFormat.postal[0] && "Inviter"}
                </button>
              </td>
            )}
          </tr>
          {showInvitationsHistoryButton && (
            <tr>
              <td className="px-4 py-2" colSpan={3} style={{ cursor: "pointer" }}>
                {!showInvitationsHistory && (
                  <button onClick={() => setShowInvitationsHistory(true)} type="button">
                    <i className="fas fa-angle-down" /> Voir l&apos;historique{" "}
                    <i className="fas fa-angle-down" />
                  </button>
                )}
                {showInvitationsHistory && (
                  <button onClick={() => setShowInvitationsHistory(false)} type="button">
                    <i className="fas fa-angle-up" /> Voir moins <i className="fas fa-angle-up" />
                  </button>
                )}
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
