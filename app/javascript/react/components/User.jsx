import React from "react";
import { observer } from "mobx-react-lite";

import ContactInfosExtraLine from "./user/ContactInfosExtraLine";
import InvitationCells from "./user/InvitationCells";

function User({ user }) {
  const computeInvitationsColspan = () => {
    let colSpan = 0;
    if (user.canBeInvitedBy("sms")) colSpan += 1;
    if (user.canBeInvitedBy("email")) colSpan += 1;
    if (user.canBeInvitedBy("postal")) colSpan += 1;
    return colSpan;
  };

  return (
    <>
      <tr className={user.isArchivedInCurrentDepartment() || !user.isValid ? "table-danger" : ""}>
        {user.list.columns.map((column) => {
          if (!column.visible || !column.content) return null
          
          return <td key={column.name} className={user[`${column.key}Updated`] ? "table-success" : ""}>{column.content({ user })}</td>
        })}

        {user.currentConfiguration && (
          <InvitationCells
            user={user}
            invitationsColspan={computeInvitationsColspan()}
          />
        )}
      </tr>

      {/* Contact infos extra line. It appears if the user contacts data when uploading the contacts file are different from the ones in DB */}

      {(user.belongsToCurrentOrg() && (user.phoneNumberNew || user.emailNew || user.rightsOpeningDateNew)) && (
        <ContactInfosExtraLine user={user} invitationsColspan={computeInvitationsColspan()} />
      )}
    </>
  );
}

export default observer(User);
