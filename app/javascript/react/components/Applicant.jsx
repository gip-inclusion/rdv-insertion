import React, { useState } from "react";
import Swal from "sweetalert2";
import createApplicant from "../actions/createApplicant";
import inviteApplicant from "../actions/inviteApplicant";

export default function Applicant({ applicant, dispatchApplicants, department }) {
  const [isLoading, setIsLoading] = useState(
    {account_creation: false, sms_invitation: false, email_invitation: false}
  );

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

  const handleApplicantInvitation = async (invitationFormat) => {
    const result = await inviteApplicant(applicant.id, invitationFormat);
    if (result.success) {
      const { invitation } = result;
      if (invitationFormat === "sms") {
        applicant.smsInvitationSentAt = invitation.sent_at;
      } else if (invitationFormat === "email") {
        applicant.emailInvitationSentAt = invitation.sent_at;
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
    setIsLoading({...isLoading, [action]: true});
    if (action === "account_creation") {
      await handleApplicantCreation();
    } else if (action === "sms_invitation") {
      await handleApplicantInvitation("sms");
    } else if (action === "email_invitation") {
      await handleApplicantInvitation("email");
    }
    setIsLoading({...isLoading, [action]: false});
  };

  return (
    <tr key={applicant.uid}>
      <td>{applicant.affiliationNumber}</td>
      <td>{applicant.short_title}</td>
      <td>{applicant.firstName}</td>
      <td>{applicant.lastName}</td>
      <td>{applicant.fullAddress}</td>
      <td>{applicant.short_role}</td>
      {applicant.shouldDisplay("birth_date") && <td>{applicant.birthDate ?? " - "}</td>}
      {applicant.shouldDisplay("email") && <td>{applicant.email ?? " - "}</td>}
      {applicant.shouldDisplay("phone_number") && <td>{applicant.phoneNumber ?? " - "}</td>}
      {applicant.shouldDisplay("custom_id") && <td>{applicant.customId ?? " - "}</td>}
      <td>
        {applicant.createdAt ??
          <button
            type="submit"
            disabled={isLoading.account_creation}
            className="btn btn-primary btn-blue"
            onClick={() => handleClick("account_creation")}
          >
            {isLoading.account_creation ? "Création..." : "Créer compte"}
          </button>
        }
      </td>
      {applicant.shouldBeInvited() && (
        <>
          <td>
            {applicant.smsInvitationSentAt ??
              <button
                type="submit"
                disabled={isLoading.sms_invitation}
                className="btn btn-primary btn-blue"
                onClick={() => handleClick("sms_invitation")}
              >
                {isLoading.sms_invitation ? "Invitation..." : "Inviter par SMS"}
              </button>
            }
          </td>
          <td>
            {applicant.emailInvitationSentAt ??
              <button
                type="submit"
                disabled={isLoading.email_invitation}
                className="btn btn-primary btn-blue"
                onClick={() => handleClick("email_invitation")}
              >
                {isLoading.email_invitation ? "Invitation..." : "Inviter par mail"}
              </button>

            }
          </td>
        </>
      )}
    </tr>
  );
}
