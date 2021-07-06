import React, { useState } from "react";
import Swal from "sweetalert2";
import createApplicant from "../actions/createApplicant";
import inviteApplicant from "../actions/inviteApplicant";

export default function Applicant({ applicant, dispatchApplicants }) {
  const [isLoading, setIsLoading] = useState(false);

  const handleApplicantCreation = async () => {
    const result = await createApplicant(applicant);
    if (result.success) {
      applicant.augmentWith(result.augmented_applicant);

      dispatchApplicants({
        type: "update",
        item: {
          seed: applicant.uid,
          applicant,
        },
      });
    } else {
      Swal.fire("Impossible de créer l'utilisateur", result.errors[0], "error");
    }
  };

  const handleApplicantInvitation = async () => {
    const result = await inviteApplicant(applicant.id);
    if (result.success) {
      const { invitation } = result;
      applicant.invitationSentAt = invitation.sent_at;

      dispatchApplicants({
        type: "update",
        item: {
          seed: applicant.uid,
          applicant,
        },
      });
    } else {
      Swal.fire("Impossible d'inviter l'utilisateur", result.errors[0], "error");
    }
  };

  const handleClick = async () => {
    setIsLoading(true);
    if (applicant.callToAction() === "CREER COMPTE") {
      await handleApplicantCreation();
    } else if (["INVITER", "REINVITER"].includes(applicant.callToAction())) {
      await handleApplicantInvitation();
    }
    setIsLoading(false);
  };

  return (
    <tr key={applicant.uid}>
      <td>{applicant.affiliationNumber}</td>
      <td>{applicant.firstName}</td>
      <td>{applicant.lastName}</td>
      <td>{applicant.fullAddress()}</td>
      <td>{applicant.email}</td>
      <td>{applicant.phoneNumber}</td>
      <td>{applicant.birthDate}</td>
      <td>{applicant.role}</td>
      <td className="text-nowrap">{applicant.createdAt ?? " - "}</td>
      <td className="text-nowrap">{applicant.invitationSentAt ?? " - "}</td>
      <td>
        {!applicant.invitedAt && (
          <button
            type="submit"
            disabled={isLoading}
            className="btn btn-primary"
            onClick={() => handleClick()}
          >
            {isLoading ? applicant.loadingAction() : applicant.callToAction()}
          </button>
        )}
      </td>
    </tr>
  );
}
