import React, { useState } from "react";
import Swal from "sweetalert2";
import createApplicant from "../actions/createApplicant";
import inviteApplicant from "../actions/inviteApplicant";

export default function Applicant({ applicant, dispatchApplicants, department }) {
  const [isLoading, setIsLoading] = useState(false);

  const handleApplicantCreation = async () => {
    const result = await createApplicant(applicant, department.id);
    if (result.success) {
      applicant.updateWith(result.applicant);

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
      const invitation = result.invitations[0];
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
    } else if (applicant.callToAction() === "INVITER") {
      await handleApplicantInvitation();
    } else if (applicant.callToAction() === "REINVITER") {
      const confirmation = await Swal.fire({
        title: "êtes-vous sûr de vouloir réinviter le demandeur?",
        icon: "warning",
        showCancelButton: true,
        confirmButtonColor: "#3085d6",
        cancelButtonColor: "#d33",
      });

      if (confirmation.isConfirmed) {
        await handleApplicantInvitation();
      }
    }
    setIsLoading(false);
  };

  return (
    <tr key={applicant.uid}>
      <td>{applicant.affiliationNumber}</td>
      <td>{applicant.title}</td>
      <td>{applicant.firstName}</td>
      <td>{applicant.lastName}</td>
      <td>{applicant.fullAddress}</td>
      <td>{applicant.role}</td>
      {applicant.shouldDisplay("birth_date") && <td>{applicant.birthDate ?? " - "}</td>}
      {applicant.shouldDisplay("email") && <td>{applicant.email ?? " - "}</td>}
      {applicant.shouldDisplay("phone_number") && <td>{applicant.phoneNumber ?? " - "}</td>}
      {applicant.shouldDisplay("custom_id") && <td>{applicant.customId ?? " - "}</td>}
      <td className="text-nowrap">{applicant.createdAt ?? " - "}</td>
      {applicant.shouldBeInvited() && (
        <td className="text-nowrap">{applicant.invitationSentAt ?? " - "}</td>
      )}
      <td>
        {applicant.callToAction() ? (
          <button
            type="submit"
            disabled={isLoading}
            className="btn btn-primary"
            onClick={() => handleClick()}
          >
            {isLoading ? applicant.loadingAction() : applicant.callToAction()}
          </button>
        ) : (
          " - "
        )}
      </td>
    </tr>
  );
}
