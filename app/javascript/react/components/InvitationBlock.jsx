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
  const [invitationsDatesByFormat, setInvitationsDatesByFormat] = useState(
    sortInvitationsByFormatsAndDates(invitations)
  );
  const [showInvitationsHistory, setShowInvitationsHistory] = useState(false);

  // We don't display "Show history" button if there is no history to display
  const showInvitationsHistoryButton = Object.values(invitationsDatesByFormat).some(
    (invitationDates) => invitationDates.length > 1
  );

  const computeInvitationsDatesRows = () => {
    const invitationsDatesByFormatLengths = invitationFormats.map(
      (format) => invitationsDatesByFormat[format].length
    );
    const numberOfInvitationsDatesRowsNeeded = showInvitationsHistory
      ? Math.max(...invitationsDatesByFormatLengths)
      : 1;
    const invitationsDatesRows = [];
    for (let i = 0; i < numberOfInvitationsDatesRowsNeeded; i += 1) {
      invitationsDatesRows.push(
        <InvitationsDatesRow
          invitationsDatesByFormat={invitationsDatesByFormat}
          invitationFormats={invitationFormats}
          index={i}
          key={`${context}${i}`}
        />
      );
    }
    return invitationsDatesRows;
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
    setInvitationsDatesByFormat((prevState) => ({
      ...prevState,
      [format]: [newInvitationDate, ...prevState[format]],
    }));
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
          {computeInvitationsDatesRows().map((invitationDateRow) => invitationDateRow)}
          <tr>
            {showInvitation("sms") && (
              <td className="px-4 py-3">
                <button
                  type="button"
                  disabled={
                    isLoading.sms ||
                    !applicant.phone_number ||
                    applicant.is_archived === true ||
                    status === "rdv_pending"
                  }
                  className="btn btn-blue"
                  onClick={() => handleInvitationClick("sms")}
                >
                  {isLoading.sms && "Invitation..."}
                  {!isLoading.sms && invitationsDatesByFormat.sms[0] && "Relancer"}
                  {!isLoading.sms && !invitationsDatesByFormat.sms[0] && "Inviter"}
                </button>
              </td>
            )}
            {showInvitation("email") && (
              <td className="px-4 py-3">
                <button
                  type="button"
                  disabled={
                    isLoading.email ||
                    !applicant.email ||
                    applicant.is_archived === true ||
                    status === "rdv_pending"
                  }
                  className="btn btn-blue"
                  onClick={() => handleInvitationClick("email")}
                >
                  {isLoading.email && "Invitation..."}
                  {!isLoading.email && invitationsDatesByFormat.email[0] && "Relancer"}
                  {!isLoading.email && !invitationsDatesByFormat.email[0] && "Inviter"}
                </button>
              </td>
            )}
            {showInvitation("postal") && (
              <td className="px-4 py-3">
                <button
                  type="button"
                  disabled={
                    isLoading.postal ||
                    !applicant.address ||
                    applicant.is_archived === true ||
                    status === "rdv_pending"
                  }
                  className="btn btn-blue"
                  onClick={() => handleInvitationClick("postal")}
                >
                  {isLoading.postal && "Invitation..."}
                  {!isLoading.postal && invitationsDatesByFormat.postal[0] && "Recréer"}
                  {!isLoading.postal && !invitationsDatesByFormat.postal[0] && "Inviter"}
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
