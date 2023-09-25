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

export default observer(({ user, format, isDepartmentLevel }) => {
  const handleInvitationClick = async () => {
    user.inviteBy(format, isDepartmentLevel);
  };

  const actionType = `${format}Invitation`;

  return (
    user.canBeInvitedBy(format) && (
      <>
        <td>
          {user.markAsAlreadyInvitedBy(format) ? (
            <Tippy
              content={
                <span>Invité le {getFrenchFormatDateString(user.lastInvitationDate(format))}</span>
              }
            >
              <i className="fas fa-check" />
            </Tippy>
          ) : user.errors.includes(actionType) ? (
            <button
              type="submit"
              className="btn btn-danger"
              onClick={() => handleInvitationClick()}
            >
              Résoudre les erreurs
            </button>
          ) : (
            <button
              type="submit"
              disabled={
                user.triggers[actionType] ||
                !user.createdAt ||
                !user.requiredAttributeToInviteBy(format) ||
                !user.belongsToCurrentOrg()
              }
              className="btn btn-primary btn-blue"
              onClick={() => handleInvitationClick()}
            >
              {user.triggers[actionType]
                ? "Invitation..."
                : user.hasParticipations()
                ? CTA_BY_FORMAT[format].secondTime
                : CTA_BY_FORMAT[format].firstTime}
            </button>
          )}
        </td>
      </>
    )
  );
});
