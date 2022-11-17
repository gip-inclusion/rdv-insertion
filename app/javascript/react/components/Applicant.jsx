import React, { useState } from "react";

import CreationCell from "./applicant/CreationCell";
import InvitationCells from "./applicant/InvitationCells";
import ContactInfosExtraLine from "./applicant/ContactInfosExtraLine";

export default function Applicant({ applicant, isDepartmentLevel }) {
  const [isTriggered, setIsTriggered] = useState({
    creation: false,
    unarchiving: false,
    smsInvitation: false,
    emailInvitation: false,
    postalInvitation: false,
    emailUpdate: false,
    phoneNumberUpdate: false,
    rightsOpeningDateUpdate: false,
    allAttributesUpdate: false,
  });

  const computeInvitationsColspan = () => {
    let colSpan = 0;
    if (applicant.canBeInvitedBySms()) colSpan += 1;
    if (applicant.canBeInvitedByEmail()) colSpan += 1;
    if (applicant.canBeInvitedByPostal()) colSpan += 1;
    return colSpan;
  };

  return (
    <>
      <tr className={applicant.isDuplicate || applicant.isArchived ? "table-danger" : ""}>
        <td>{applicant.affiliationNumber}</td>
        <td>{applicant.shortTitle}</td>
        <td>{applicant.firstName}</td>
        <td>{applicant.lastName}</td>
        <td>{applicant.shortRole}</td>
        {applicant.shouldDisplay("department_internal_id") && (
          <td>{applicant.departmentInternalId ?? " - "}</td>
        )}
        {applicant.shouldDisplay("birth_date") && <td>{applicant.birthDate ?? " - "}</td>}
        {applicant.shouldDisplay("email") && (
          <td className={applicant.emailUpdated ? "table-success" : ""}>
            {applicant.email ?? " - "}
          </td>
        )}
        {applicant.shouldDisplay("phone_number") && (
          <td className={applicant.phoneNumberUpdated ? "table-success" : ""}>
            {applicant.phoneNumber ?? " - "}
          </td>
        )}
        {applicant.shouldDisplay("rights_opening_date") && (
          <td className={applicant.rightsOpeningDateUpdated ? "table-success" : ""}>
            {applicant.rightsOpeningDate ?? " - "}
          </td>
        )}

        {/* ------------------------------- Account creation cell ----------------------------- */}

        <CreationCell
          applicant={applicant}
          isDepartmentLevel={isDepartmentLevel}
          isTriggered={isTriggered}
          setIsTriggered={setIsTriggered}
        />
        {/* --------------------------------- Invitations cells ------------------------------- */}

        <InvitationCells
          applicant={applicant}
          invitationsColspan={computeInvitationsColspan()}
          isDepartmentLevel={isDepartmentLevel}
          isTriggered={isTriggered}
          setIsTriggered={setIsTriggered}
        />
      </tr>

      {/* Contact infos extra line. It appears if the applicant contacts data when uploading the contacts file are different from the ones in DB */}

      {(applicant.phoneNumberNew || applicant.emailNew || applicant.rightsOpeningDateNew) && (
        <ContactInfosExtraLine
          applicant={applicant}
          invitationsColspan={computeInvitationsColspan()}
          isTriggered={isTriggered}
          setIsTriggered={setIsTriggered}
        />
      )}
    </>
  );
}
