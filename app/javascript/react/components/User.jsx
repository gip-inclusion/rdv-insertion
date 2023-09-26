import React from "react";
import { observer } from "mobx-react-lite";

import CreationCell from "./user/CreationCell";
import InvitationCells from "./user/InvitationCells";
import ContactInfosExtraLine from "./user/ContactInfosExtraLine";
import ReferentAssignationCell from "./user/ReferentAssignationCell";
import CarnetCreationCell from "./user/CarnetCreationCell";
import EditableCell from "./user/EditableCell";

function User({ user, isDepartmentLevel, showCarnetColumn, showReferentColumn }) {
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
        <td>
          <input
            type="checkbox"
            className="form-check-input"
            checked={user.selected}
            onChange={(event) => {
              user.selected = event.target.checked;
            }}
          />
        </td>
        <td>
          <EditableCell
            type="select"
            user={user}
            cell="title"
            values={[
              { key: "M", value: "monsieur" },
              { key: "Mme", value: "madame" },
            ]}
          />
        </td>
        <td>
          <EditableCell user={user} cell="firstName" />
        </td>
        <td>
          <EditableCell user={user} cell="lastName" />
        </td>
        {user.shouldDisplay("affiliation_number_column") && (
          <td>
            <EditableCell user={user} cell="affiliationNumber" />
          </td>
        )}
        {user.shouldDisplay("role_column") && (
          <td>
            <EditableCell
              user={user}
              cell="role"
              type="select"
              values={[
                { key: "DEM", value: "demandeur" },
                { key: "CJT", value: "conjoint" },
              ]}
            />
          </td>
        )}
        {user.shouldDisplay("department_internal_id_column") && (
          <td>
            <EditableCell user={user} cell="departmentInternalId" />
          </td>
        )}
        {user.shouldDisplay("nir_column") && <td>{user.nir ?? " - "}</td>}
        {user.shouldDisplay("pole_emploi_id_column") && <td>{user.poleEmploiId ?? " - "}</td>}
        {user.shouldDisplay("email_column") && (
          <td className={user.emailUpdated ? "table-success" : ""}>
            <EditableCell user={user} cell="email" />
          </td>
        )}
        {user.shouldDisplay("phone_number_column") && (
          <td className={user.phoneNumberUpdated ? "table-success" : ""}>
            <EditableCell user={user} cell="phoneNumber" />
          </td>
        )}
        {user.shouldDisplay("tags_column") && (
          <td className={user.tagsUpdated ? "table-success" : ""}>
            <EditableCell
              user={user}
              cell="tags"
              type="tags"
              values={user.availableTags.map((tag) => tag.value)}
            />
          </td>
        )}
        {user.shouldDisplay("rights_opening_date_column") && (
          <td className={user.rightsOpeningDateUpdated ? "table-success" : ""}>
            <EditableCell user={user} cell="rightsOpeningDate" />
          </td>
        )}
        {/* ------------------------------- Account creation cell ----------------------------- */}

        <CreationCell user={user} isDepartmentLevel={isDepartmentLevel} />

        {/* ------------------------------- Carnet creation cell ----------------------------- */}

        {showCarnetColumn && <CarnetCreationCell user={user} />}

        {/* ------------------------------- Referent cell ----------------------------- */}

        {showReferentColumn && (
          <ReferentAssignationCell user={user} isDepartmentLevel={isDepartmentLevel} />
        )}

        {/* --------------------------------- Invitations cells ------------------------------- */}
        {user.currentConfiguration && (
          <InvitationCells
            user={user}
            invitationsColspan={computeInvitationsColspan()}
            isDepartmentLevel={isDepartmentLevel}
          />
        )}
      </tr>

      {/* Contact infos extra line. It appears if the user contacts data when uploading the contacts file are different from the ones in DB */}

      {(user.id && (user.phoneNumberNew || user.emailNew || user.rightsOpeningDateNew)) && (
        <ContactInfosExtraLine user={user} invitationsColspan={computeInvitationsColspan()} />
      )}
    </>
  );
}

export default observer(User);
