import React from "react";
import { observer } from "mobx-react-lite";
import Tippy from "@tippyjs/react";

import { getFrenchFormatDateString } from "../../../lib/datesHelper";

const CTA_BY_FORMAT = {
  sms: "Inviter par SMS",
  email: "Inviter par Email",
  postal: "Générer courrier",
};

export default observer(({ user, format }) => {
  const handleInvitationClick = async () => {
    user.inviteBy(format);
  };

  const actionType = `${format}Invitation`;

  const inviteButtonContent = () => {
    if (user.triggers[actionType]) {
      if (user.lastInvitationDate(format)) return <i className="ri-refresh-line" />;
      return "Invitation...";
    }

    if (user.lastInvitationDate(format)) return (
      <i className="ri-repeat-2-line small-wheel d-block p-1" />
    )

    return CTA_BY_FORMAT[format];
  };

  return (
    user.list.canBeInvitedBy(format) && (
      <td>
        {user.activeErrors.includes(actionType) ? (
          <button
            type="submit"
            className="btn btn-danger"
            onClick={() => handleInvitationClick()}
          >
            Afficher les erreurs
          </button>
        ) : (
          <Tippy
            onShow={() => user.lastInvitationDate(format) !== undefined}
            content={
              <span>
                {user.lastInvitationDate(format) &&
                  `Dernière invitation ${format} le ${getFrenchFormatDateString(user.lastInvitationDate(format))}`
                }
                {user.lastInvitationDate(format) && user.lastParticipationRdvStartsAt() && <br />}
                {user.lastParticipationRdvStartsAt() &&
                  `Dernier rendez-vous le ${getFrenchFormatDateString(user.lastParticipationRdvStartsAt())}`
                }
              </span>
            }
          >
            <div className="d-flex justify-content-center">
              {user.lastInvitationDate(format) !== undefined && (
                <i className="ri-check-line d-block p-1" />
              )}
              <button
                type="submit"
                disabled={
                  user.triggers[actionType] ||
                  !user.createdAt ||
                  !user.requiredAttributeToInviteBy(format) ||
                  !user.belongsToCurrentOrg()
                }
                className={
                  user.lastInvitationDate(format) === undefined ? `btn btn-primary btn-blue invitation-${format}` : `reinvitation-${format}`
                }
                onClick={() => handleInvitationClick()}
              >
                {inviteButtonContent()}
              </button>
            </div>
          </Tippy>
        )}
      </td>
    )
  );
});
