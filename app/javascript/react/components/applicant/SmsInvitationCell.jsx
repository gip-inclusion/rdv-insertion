import React, { useState } from "react";
import Swal from "sweetalert2";
import Tippy from "@tippyjs/react";

import handleApplicantInvitation from "../../lib/handleApplicantInvitation";
import { getFrenchFormatDateString } from "../../../lib/datesHelper";

export default function SmsInvitationCell({
  applicant,
  isTriggered,
  setIsTriggered,
  isDepartmentLevel,
}) {
  const handleSmsInvitationClick = async () => {
    setIsTriggered({ ...isTriggered, smsInvitation: true });
    const invitationParams = [
      applicant.id,
      applicant.department.id,
      applicant.currentOrganisation.id,
      isDepartmentLevel,
      applicant.currentConfiguration.motif_category,
      applicant.currentOrganisation.phone_number,
    ];
    const result = await handleApplicantInvitation(...invitationParams, "sms");
    applicant.lastSmsInvitationSentAt = result.invitation.sent_at;

    setIsTriggered({ ...isTriggered, smsInvitation: false });
  };

  return (
    applicant.shouldBeInvitedBySms() && (
      <>
        <td>
          {applicant.lastSmsInvitationSentAt ? (
            <Tippy
              content={
                <span>
                  Invité le {getFrenchFormatDateString(applicant.lastSmsInvitationSentAt)}
                </span>
              }
            >
              <i className="fas fa-check" />
            </Tippy>
          ) : (
            <button
              type="submit"
              disabled={
                isTriggered.smsInvitation ||
                !applicant.createdAt ||
                !applicant.phoneNumber ||
                !applicant.belongsToCurrentOrg()
              }
              className="btn btn-primary btn-blue"
              onClick={() => handleSmsInvitationClick()}
            >
              {isTriggered.smsInvitation
                ? "Invitation..."
                : applicant.hasRdvs()
                ? "Réinviter par SMS"
                : "Inviter par SMS"}
            </button>
          )}
        </td>
      </>
    )
  );
}
