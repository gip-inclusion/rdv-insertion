import React, { useState } from "react";
import Swal from "sweetalert2";
import Tippy from "@tippyjs/react";

import handleApplicantInvitation from "../../lib/handleApplicantInvitation";
import { getFrenchFormatDateString } from "../../../lib/datesHelper";

export default function EmailInvitationCell({
  applicant,
  isTriggered,
  setIsTriggered,
  isDepartmentLevel,
}) {
  const [isLoading, setIsLoading] = useState(false);

  const handleEmailInvitationClick = async () => {
    setIsTriggered({ ...isTriggered, emailInvitation: true });
    const invitationParams = [
      applicant.id,
      applicant.department.id,
      applicant.currentOrganisation.id,
      isDepartmentLevel,
      applicant.currentConfiguration.motif_category,
      applicant.currentOrganisation.phone_number,
    ];
    const result = await handleApplicantInvitation(...invitationParams, "email");
    applicant.lastEmailInvitationSentAt = result.invitation.sent_at;

    setIsTriggered({ ...isTriggered, emailInvitation: false });
  };

  return (
    applicant.shouldBeInvitedByEmail() && (
      <>
        <td>
          {applicant.lastEmailInvitationSentAt ? (
            <Tippy
              content={
                <span>
                  Invité le {getFrenchFormatDateString(applicant.lastEmailInvitationSentAt)}
                </span>
              }
            >
              <i className="fas fa-check" />
            </Tippy>
          ) : (
            <button
              type="submit"
              disabled={
                isTriggered.emailInvitation ||
                !applicant.createdAt ||
                !applicant.phoneNumber ||
                !applicant.belongsToCurrentOrg()
              }
              className="btn btn-primary btn-blue"
              onClick={() => handleEmailInvitationClick()}
            >
              {isTriggered.emailInvitation ? "Invitation..." : "Inviter par Email"}
            </button>
          )}
        </td>
      </>
    )
  );
}
