import React, { useState } from "react";
import Swal from "sweetalert2";
import confirmationModal from "../../lib/confirmationModal";
import createApplicant from "../actions/createApplicant";
import inviteApplicant from "../actions/inviteApplicant";

export default function Applicant({ applicant, dispatchApplicants, organisation }) {
  const [isLoading, setIsLoading] = useState({
    accountCreation: false,
    smsInvitation: false,
    emailInvitation: false,
  });

  const displayDuplicationWarning = async () => {
    let warningMessage = "";

    if (!applicant.affiliationNumber) {
      warningMessage =
        "Le numéro d'allocataire n'est pas spécifié (si c'est un NIR il a été filtré).";
    } else if (!applicant.role) {
      warningMessage = "Le rôle de l'allocataire n'est pas spécifié.";
    }

    const searchApplicantLink = new URL(
      `${window.location.origin}/organisations/${organisation.id}/applicants`
    );
    searchApplicantLink.searchParams.set("search_query", applicant.lastName);

    return confirmationModal(
      `${warningMessage}\nVérifiez <a class="light-blue" href="${searchApplicantLink.href}" target="_blank">ici</a>` +
        " que l'allocataire n'a pas déjà été créé avant de continuer.",
      {
        confirmButtonText: "Créer",
        cancelButtonText: "Annuler",
      }
    );
  };

  const handleApplicantCreation = async () => {
    if (!applicant.affiliationNumber || !applicant.role) {
      const confirmation = await displayDuplicationWarning();
      if (!confirmation.isConfirmed) return;
    }
    const result = await createApplicant(applicant, organisation.id);
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

  const handleApplicantInvitation = async (invitationFormat) => {
    const result = await inviteApplicant(organisation.id, applicant.id, invitationFormat);
    if (result.success) {
      const { invitation } = result;
      if (invitationFormat === "sms") {
        applicant.lastSmsInvitationSentAt = invitation.sent_at;
      } else if (invitationFormat === "email") {
        applicant.lastEmailInvitationSentAt = invitation.sent_at;
      }

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

  const handleClick = async (action) => {
    setIsLoading({ ...isLoading, [action]: true });
    if (action === "accountCreation") {
      await handleApplicantCreation();
    } else if (action === "smsInvitation") {
      await handleApplicantInvitation("sms");
    } else if (action === "emailInvitation") {
      await handleApplicantInvitation("email");
    }
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
