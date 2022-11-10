import React, { useState } from "react";
import Swal from "sweetalert2";
import Tippy from "@tippyjs/react";

import handleApplicantInvitation from "../../lib/handleApplicantInvitation";
import { todaysDateString } from "../../../lib/datesHelper";
import { getFrenchFormatDateString } from "../../../lib/datesHelper";

export default function PostalInvitationCell({
  applicant,
  isTriggered,
  setIsTriggered,
  isDepartmentLevel,
}) {
  const handlePostalInvitationClick = async () => {
    setIsTriggered({ ...isTriggered, postalInvitation: true });
    const invitationParams = [
      applicant.id,
      applicant.department.id,
      applicant.currentOrganisation.id,
      isDepartmentLevel,
      applicant.currentConfiguration.motif_category,
      applicant.currentOrganisation.phone_number,
    ];
    const createLetter = await handleApplicantInvitation(...invitationParams, "postal");
    if (createLetter?.success) {
      applicant.lastPostalInvitationSentAt = todaysDateString();
    }

    setIsTriggered({ ...isTriggered, postalInvitation: false });
  };

  return (
    applicant.shouldBeInvitedByPostal() && (
      <>
        <td>
          {applicant.lastPostalInvitationSentAt ? (
            <Tippy
              content={
                <span>
                  Invité le {getFrenchFormatDateString(applicant.lastPostalInvitationSentAt)}
                </span>
              }
            >
              <i className="fas fa-check" />
            </Tippy>
          ) : (
            <button
              type="submit"
              disabled={
                isTriggered.postalInvitation ||
                !applicant.createdAt ||
                !applicant.fullAddress ||
                !applicant.belongsToCurrentOrg()
              }
              className="btn btn-primary btn-blue"
              onClick={() => handlePostalInvitationClick()}
            >
              {isTriggered.postalInvitation ? "Création en cours..." : "Générer courrier"}
            </button>
          )}
        </td>
      </>
    )
  );
}
