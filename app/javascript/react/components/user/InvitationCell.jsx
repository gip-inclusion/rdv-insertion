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
                  <i className="fas fa-check d-block p-1" />
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
                      user.lastInvitationDate(format) === undefined || user.triggers[actionType] ? `btn btn-primary btn-blue invitation-${format}` : `reinvitation-${format}`
                    }
                  onClick={() => handleInvitationClick()}
                >
                    {user.triggers[actionType] ? "Invitation..."
                      : user.lastInvitationDate(format) === undefined ? (
                        CTA_BY_FORMAT[format]
                      ) : (
                        < i className="fas fa-redo-alt small-wheel d-block p-1" />
                      )
                    }
                </button>
              </div>
            </Tippy>
          )}
        </td>
      </>
    )
  );
});
