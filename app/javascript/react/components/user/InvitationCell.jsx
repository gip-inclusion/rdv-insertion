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

export default observer(({ user, format }) => {
  const handleInvitationClick = async () => {
    user.inviteBy(format);
  };

  const actionType = `${format}Invitation`;

  return (
    user.list.canBeInvitedBy(format) && (
      <>
        <td>
          {user.errors.includes(actionType) ? (
            <button
              type="submit"
              className="btn btn-danger"
              onClick={() => handleInvitationClick()}
            >
              L'envoi a échoué
            </button>
          ) : (
            <Tippy
              onShow={() => user.lastInvitationDate(format) !== undefined}
              content={
                <span>
                  {user.lastInvitationDate(format) &&
                    `Dernière invitation le ${getFrenchFormatDateString(user.lastInvitationDate(format))}`
                  }
                  {user.lastInvitationDate(format) && user.lastParticipationRdvStartsAt() && <br />}
                  {user.lastParticipationRdvStartsAt() &&
                    `Dernier rendez-vous le ${getFrenchFormatDateString(user.lastParticipationRdvStartsAt())}`
                  }
                </span>
              }
            >
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
                {user.triggers[actionType] ? "Invitation..."
                  : user.hasParticipations() || user.lastInvitationDate(format) ? CTA_BY_FORMAT[format].secondTime
                  : CTA_BY_FORMAT[format].firstTime}
                </button>
            </Tippy>
          )}
        </td>
      </>
    )
  );
});
