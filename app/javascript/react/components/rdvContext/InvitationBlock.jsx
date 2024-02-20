import React, { useState } from "react";
import Tippy from "@tippyjs/react";
import InvitationsDatesRow from "./InvitationsDatesRow";

import sortInvitationsByFormatsAndDates from "../../../lib/sortInvitationsByFormatsAndDates";
import handleUserInvitation from "../../lib/handleUserInvitation";
import { todaysDateString } from "../../../lib/datesHelper";

export default function InvitationBlock({
  user,
  invitations,
  organisation,
  department,
  motifCategory,
  isDepartmentLevel,
  invitationFormats,
  status,
  isArchived,
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
  const [numberOfInvitationsDatesRowsNeeded, setNumberOfInvitationsDatesRowsNeeded] = useState(1);

  // We don't display "Show history" button if there is no history to display
  const showInvitationsHistoryButton = Object.values(invitationsDatesByFormat).some(
    (invitationDates) => invitationDates.length > 1
  );

  const updateStatusBlock = () => {
    const statusBlock = document.getElementById(`js-block-status-${motifCategory.id}`);
    if (statusBlock) {
      statusBlock.innerHTML = "<em>Invitation en attente de réponse</em>";
    }
  };

  const showInvitation = (format) => invitationFormats.includes(format);

  const handleShowInvitationsHistory = () => {
    setShowInvitationsHistory(true);
    setNumberOfInvitationsDatesRowsNeeded(
      Math.max(...invitationFormats.map((format) => invitationsDatesByFormat[format].length))
    );
  };

  const handleHideInvitationsHistory = () => {
    setShowInvitationsHistory(false);
    setNumberOfInvitationsDatesRowsNeeded(1);
  };

  const handleInvitationClick = async (format) => {
    setIsLoading({ ...isLoading, [format]: true });
    const userParams = [
      user.id,
      department.id,
      organisation.id,
      isDepartmentLevel,
      motifCategory.id,
    ];
    let newInvitationDate;

    const result = await handleUserInvitation(...userParams, format);
    if (format === "postal" && result.success) {
      newInvitationDate = todaysDateString();
    } else {
      newInvitationDate = result.invitation?.sent_at;
    }
    if (newInvitationDate) {
      setInvitationsDatesByFormat((prevState) => ({
        ...prevState,
        [format]: [newInvitationDate, ...prevState[format]],
      }));
      updateStatusBlock();
    }
    setIsLoading({ ...isLoading, [format]: false });
  };

  return (
    <div className="d-flex justify-content-center">
      <table className="card-white text-center align-middle m-3 shadow-sm">
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
          {[...Array(numberOfInvitationsDatesRowsNeeded).keys()].map((idx) => (
            <InvitationsDatesRow
              invitationsDatesByFormat={invitationsDatesByFormat}
              invitationFormats={invitationFormats}
              index={idx}
              key={`${motifCategory}${idx}`}
            />
          ))}
          <tr>
            {showInvitation("sms") && (
              <td className="px-4 py-3">
                <button
                  type="button"
                  disabled={
                    isLoading.sms ||
                    !user.phone_number ||
                    isArchived ||
                    status === "rdv_pending" ||
                    status === "closed"
                  }
                  className="btn btn-blue"
                  onClick={() => handleInvitationClick("sms")}
                >
                  {isLoading.sms && "Invitation..."}
                  {!isLoading.sms && invitationsDatesByFormat.sms[0] && (
                    <Tippy
                      content="Réinviter remettra les compteurs à 0 vis à vis des délais"
                      placement="bottom"
                    >
                      <span>Réinviter</span>
                    </Tippy>
                  )}
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
                    !user.email ||
                    isArchived ||
                    status === "rdv_pending" ||
                    status === "closed"
                  }
                  className="btn btn-blue"
                  onClick={() => handleInvitationClick("email")}
                >
                  {isLoading.email && "Invitation..."}
                  {!isLoading.email && invitationsDatesByFormat.email[0] && (
                    <Tippy
                      content="Réinviter remettra les compteurs à 0 vis à vis des délais"
                      placement="bottom"
                    >
                      <span>Réinviter</span>
                    </Tippy>
                  )}
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
                    !user.address ||
                    isArchived ||
                    status === "rdv_pending" ||
                    status === "closed"
                  }
                  className="btn btn-blue"
                  onClick={() => handleInvitationClick("postal")}
                >
                  {isLoading.postal && "Invitation..."}
                  {!isLoading.postal && invitationsDatesByFormat.postal[0] && (
                    <Tippy
                      content="Réinviter remettra les compteurs à 0 vis à vis des délais"
                      placement="bottom"
                    >
                      <span>Réinviter</span>
                    </Tippy>
                  )}
                  {!isLoading.postal && !invitationsDatesByFormat.postal[0] && "Inviter"}
                </button>
              </td>
            )}
          </tr>
          {showInvitationsHistoryButton && (
            <tr>
              <td className="px-4 py-2" colSpan={3} style={{ cursor: "pointer" }}>
                {!showInvitationsHistory && (
                  <button onClick={handleShowInvitationsHistory} type="button">
                    <i className="fas fa-angle-down" /> Voir l&apos;historique{" "}
                    <i className="fas fa-angle-down" />
                  </button>
                )}
                {showInvitationsHistory && (
                  <button onClick={handleHideInvitationsHistory} type="button">
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
