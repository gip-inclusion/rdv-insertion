import React from "react";
import { observer } from "mobx-react-lite";
import Tippy from "@tippyjs/react";

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
    applicant.inviteBy(format, isDepartmentLevel);
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
