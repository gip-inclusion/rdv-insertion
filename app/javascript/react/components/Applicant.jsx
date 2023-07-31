import React from "react";
import { observer } from "mobx-react-lite";

import CreationCell from "./applicant/CreationCell";
import InvitationCells from "./applicant/InvitationCells";
import ContactInfosExtraLine from "./applicant/ContactInfosExtraLine";
import ReferentAssignationCell from "./applicant/ReferentAssignationCell";
import CarnetCreationCell from "./applicant/CarnetCreationCell";
import EditableCell from "./applicant/EditableCell";

function Applicant({
  applicant,
  isDepartmentLevel,
  showCarnetColumn,
  showReferentColumn,
}) {
  const computeInvitationsColspan = () => {
    let colSpan = 0;
    if (applicant.canBeInvitedBy("sms")) colSpan += 1;
    if (applicant.canBeInvitedBy("email")) colSpan += 1;
    if (applicant.canBeInvitedBy("postal")) colSpan += 1;
    return colSpan;
  };

  return (
    <>
      <tr className={applicant.isArchivedInCurrentDepartment() || !applicant.isValid ? "table-danger" : ""}>
        <td>
          <input
            type="checkbox"
            className="form-check-input"
            checked={applicant.selected}
            onChange={event => { applicant.selected = event.target.checked }}
          />
        </td>
        <td>
          <EditableCell
            type="select"
            applicant={applicant}
            cell="title"
            value={applicant.title}
            values={[
              { key: "M", value: "monsieur" },
              { key: "Mme", value: "madame" },
            ]}
          />
        </td>
        <td><EditableCell applicant={applicant} cell="firstName" /></td>
        <td><EditableCell applicant={applicant} cell="lastName" /></td>
        {applicant.shouldDisplay("affiliation_number_column") && (
          <td><EditableCell applicant={applicant} cell="affiliationNumber" /></td>
        )}
        {applicant.shouldDisplay("role_column") && <td><EditableCell applicant={applicant} cell="shortRole" /></td>}
        {applicant.shouldDisplay("department_internal_id_column") && (
          <td><EditableCell applicant={applicant} cell="departmentInternalId" /></td>
        )}
        {applicant.shouldDisplay("nir_column") && <td>{applicant.nir ?? " - "}</td>}
        {applicant.shouldDisplay("pole_emploi_id_column") && (
          <td>{applicant.poleEmploiId ?? " - "}</td>
        )}
        {applicant.shouldDisplay("email_column") && (
          <td className={applicant.emailUpdated ? "table-success" : ""}>
            <EditableCell applicant={applicant} cell="email" />
          </td>
        )}
        {applicant.shouldDisplay("phone_number_column") && (
          <td className={applicant.phoneNumberUpdated ? "table-success" : ""}>
            <EditableCell applicant={applicant} cell="phoneNumber" />
          </td>
        )}
        {applicant.shouldDisplay("rights_opening_date_column") && (
          <td className={applicant.rightsOpeningDateUpdated ? "table-success" : ""}>
            <EditableCell applicant={applicant} cell="rightsOpeningDate" />
          </td>
        )}
        {/* ------------------------------- Account creation cell ----------------------------- */}

        <CreationCell
          applicant={applicant}
          isDepartmentLevel={isDepartmentLevel}
        />

        {/* ------------------------------- Carnet creation cell ----------------------------- */}

        {showCarnetColumn && (
          <CarnetCreationCell
            applicant={applicant}
          />
        )}

        {/* ------------------------------- Referent cell ----------------------------- */}

        {showReferentColumn && (
          <ReferentAssignationCell
            applicant={applicant}
            isDepartmentLevel={isDepartmentLevel}
          />
        )}

        {/* --------------------------------- Invitations cells ------------------------------- */}
        {applicant.currentConfiguration && (
          <InvitationCells
            applicant={applicant}
            invitationsColspan={computeInvitationsColspan()}
            isDepartmentLevel={isDepartmentLevel}
          />
        )}
      </tr>

      {/* Contact infos extra line. It appears if the applicant contacts data when uploading the contacts file are different from the ones in DB */}

      {(applicant.phoneNumberNew || applicant.emailNew || applicant.rightsOpeningDateNew) && (
        <ContactInfosExtraLine
          applicant={applicant}
          invitationsColspan={computeInvitationsColspan()}
        />
      )}
    </>
  );
}

export default observer(Applicant)