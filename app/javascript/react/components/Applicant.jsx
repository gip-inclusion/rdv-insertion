import React, { useState } from "react";

import handleApplicantCreation from "../lib/handleApplicantCreation";
import handleApplicantInvitation from "../lib/handleApplicantInvitation";
import assignOrganisation from "../lib/assignOrganisation";

export default function Applicant({ applicant, dispatchApplicants }) {
  const [isLoading, setIsLoading] = useState({
    accountCreation: false,
    smsInvitation: false,
    emailInvitation: false,
  });

  const handleClick = async (action) => {
    setIsLoading({ ...isLoading, [action]: true });
    if (action === "accountCreation") {
      if (!applicant.organisation?.id) {
        await assignOrganisation(applicant);
        if (!applicant.organisation?.id) {
          setIsLoading({ ...isLoading, [action]: false });
          return;
        }
      }
      await handleApplicantCreation(applicant, applicant.organisation.id);
    } else if (action === "smsInvitation") {
      const invitation = await handleApplicantInvitation(
        applicant.organisation.id,
        applicant.id,
        "sms"
      );
      applicant.lastSmsInvitationSentAt = invitation.sent_at;
    } else if (action === "emailInvitation") {
      const invitation = await handleApplicantInvitation(
        applicant.organisation.id,
        applicant.id,
        "email"
      );
      applicant.lastEmailInvitationSentAt = invitation.sent_at;
    }

    dispatchApplicants({
      type: "update",
      item: {
        seed: applicant.uid,
        applicant,
      },
    });
    setIsLoading({ ...isLoading, [action]: false });
  };

  return (
    <tr key={applicant.uid}>
      <td>{applicant.affiliationNumber}</td>
      <td>{applicant.shortTitle}</td>
      <td>{applicant.firstName}</td>
      <td>{applicant.lastName}</td>
      <td>{applicant.shortRole}</td>
      {applicant.shouldDisplay("birth_date") && <td>{applicant.birthDate ?? " - "}</td>}
      {applicant.shouldDisplay("email") && <td>{applicant.email ?? " - "}</td>}
      {applicant.shouldDisplay("phone_number") && <td>{applicant.phoneNumber ?? " - "}</td>}
      {applicant.shouldDisplay("custom_id") && <td>{applicant.customId ?? " - "}</td>}
      <td>
        {applicant.createdAt ? (
          <i className="fas fa-check green-check" />
        ) : (
          <button
            type="submit"
            disabled={isLoading.accountCreation}
            className="btn btn-primary btn-blue"
            onClick={() => handleClick("accountCreation")}
          >
            {isLoading.accountCreation ? "Création..." : "Créer compte"}
          </button>
        )}
      </td>
      {applicant.shouldBeInvitedBySms() && (
        <>
          <td>
            {applicant.lastSmsInvitationSentAt ? (
              <i className="fas fa-check green-check" />
            ) : (
              <button
                type="submit"
                disabled={isLoading.smsInvitation || !applicant.createdAt || !applicant.phoneNumber}
                className="btn btn-primary btn-blue"
                onClick={() => handleClick("smsInvitation")}
              >
                {isLoading.smsInvitation ? "Invitation..." : "Inviter par SMS"}
              </button>
            )}
          </td>
        </>
      )}
      {applicant.shouldBeInvitedByEmail() && (
        <>
          <td>
            {applicant.lastEmailInvitationSentAt ? (
              <i className="fas fa-check green-check" />
            ) : (
              <button
                type="submit"
                disabled={isLoading.emailInvitation || !applicant.createdAt || !applicant.email}
                className="btn btn-primary btn-blue"
                onClick={() => handleClick("emailInvitation")}
              >
                {isLoading.emailInvitation ? "Invitation..." : "Inviter par mail"}
              </button>
            )}
          </td>
        </>
      )}
    </tr>
  );
}
