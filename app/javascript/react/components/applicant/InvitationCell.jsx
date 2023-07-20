import React from "react";
import { observer } from "mobx-react-lite";
import Tippy from "@tippyjs/react";

import handleApplicantInvitation from "../../lib/handleApplicantInvitation";
import { getFrenchFormatDateString } from "../../../lib/datesHelper";

const CTA_BY_FORMAT = {
  sms: { firstTime: "Inviter par SMS", secondTime: "Réinviter par SMS" },
  email: {
    firstTime: "Inviter par Email",
    secondTime: "Réinviter par Email",
  },
  postal: {
    firstTime: "Générer courrier",
    secondTime: "Regénérer courrier",
  },
};

export default observer(({
  applicant,
  format,
  isDepartmentLevel,
}) => {
  const handleInvitationClick = async () => {
    applicant.triggers[`${format}Invitation`] = true;
    const invitationParams = [
      applicant.id,
      applicant.department.id,
      applicant.currentOrganisation.id,
      isDepartmentLevel,
      applicant.currentConfiguration.motif_category_id,
      applicant.currentOrganisation.phone_number,
    ];
    const result = await handleApplicantInvitation(...invitationParams, format);
    if (result.success) {
      // dates are set as json to match the API format
      applicant.updateLastInvitationDate(format, new Date().toJSON());
    }
    applicant.triggers[`${format}Invitation`] = false;
  };

  return (
    applicant.canBeInvitedBy(format) && (
      <>
        <td>
          {applicant.markAsAlreadyInvitedBy(format) ? (
            <Tippy
              content={
                <span>
                  Invité le {getFrenchFormatDateString(applicant.lastInvitationDate(format))}
                </span>
              }
            >
              <i className="fas fa-check" />
            </Tippy>
          ) : (
            <button
              type="submit"
              disabled={
                applicant.triggers[`${format}Invitation`] ||
                !applicant.createdAt ||
                !applicant.requiredAttributeToInviteBy(format) ||
                !applicant.belongsToCurrentOrg()
              }
              className="btn btn-primary btn-blue"
              onClick={() => handleInvitationClick()}
            >
              {applicant.triggers[`${format}Invitation`]
                ? "Invitation..."
                : applicant.hasParticipations()
                ? CTA_BY_FORMAT[format].secondTime
                : CTA_BY_FORMAT[format].firstTime}
            </button>
          )}
        </td>
      </>
    )
  );
})
