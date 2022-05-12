import React, { useState } from "react";
import Swal from "sweetalert2";

import updateApplicant from "../actions/updateApplicant";

export default function Applicant({
  applicant,
  dispatchApplicants,
  colSpanForDisabledInvitations,
}) {
  const [isLoading, setIsLoading] = useState({
    emailUpdate: false,
    phoneNumberUpdate: false,
    rightsOpeningDateUpdate: false,
    allAttributesUpdate: false,
  });

  const handleApplicantUpdate = async (attribute = null) => {
    setIsLoading({ ...isLoading, [`${attribute}Update`]: true });
    const attributes = {};
    if (attribute === "email" || attribute === "allAttributes") {
      attributes.email = applicant.newEmail;
    }
    if (attribute === "phoneNumber" || attribute === "allAttributes") {
      attributes.phone_number = applicant.newPhoneNumber;
    }
    if (attribute === "rightsOpeningDate" || attribute === "allAttributes") {
      attributes.rights_opening_date = applicant.newRightsOpeningDate;
    }
    const result = await updateApplicant(
      applicant.currentOrganisation.id,
      applicant.id,
      attributes
    );
    if (result.success) {
      applicant.updateWith(result.applicant);
      if (attribute === "email" || (attribute === "allAttributes" && applicant.newEmail)) {
        applicant.newEmail = null;
        applicant.updatedEmail = true;
      }
      if (
        attribute === "phoneNumber" ||
        (attribute === "allAttributes" && applicant.newPhoneNumber)
      ) {
        applicant.newPhoneNumber = null;
        applicant.updatedPhoneNumber = true;
      }
      if (
        attribute === "rightsOpeningDate" ||
        (attribute === "allAttributes" && applicant.newRightsOpeningDate)
      ) {
        applicant.newRightsOpeningDate = null;
        applicant.updatedRightsOpeningDate = true;
      }
    } else {
      Swal.fire("Impossible de mettre à jour le bénéficiaire", result.errors[0], "error");
    }
    console.log(applicant);
    dispatchApplicants({
      type: "update",
      item: {
        applicant,
        seed: applicant.departmentInternalId || applicant.uid,
      },
    });

    setIsLoading({ ...isLoading, [`${attribute}Update`]: false });
  };

  const computeColSpanForContactsUpdate = () => {
    let colSpan = 5;
    if (applicant.shouldDisplay("department_internal_id")) colSpan += 1;
    if (applicant.shouldDisplay("birth_date")) colSpan += 1;
    return colSpan;
  };

  return (
    <>
      <tr className="table-success">
        <td colSpan={computeColSpanForContactsUpdate()} className="text-align-right">
          <i className="fas fa-level-up-alt" />
          Nouvelles données trouvées pour {applicant.firstName} {applicant.lastName}
        </td>
        {applicant.shouldDisplay("email") && (
          <td className="update-box">
            {applicant.newEmail && (
              <>
                {applicant.newEmail}
                <br />
                <button
                  type="submit"
                  className="btn btn-primary btn-blue btn-sm mt-2"
                  onClick={() => handleApplicantUpdate("email")}
                >
                  {isLoading.emailUpdate || isLoading.allAttributesUpdate
                    ? "En cours..."
                    : "Mettre à jour"}
                </button>
              </>
            )}
          </td>
        )}
        {applicant.shouldDisplay("phone_number") && (
          <td className="update-box">
            {applicant.newPhoneNumber && (
              <>
                {applicant.newPhoneNumber}
                <br />
                <button
                  type="submit"
                  className="btn btn-primary btn-blue btn-sm mt-2"
                  onClick={() => handleApplicantUpdate("phoneNumber")}
                >
                  {isLoading.phoneNumberUpdate || isLoading.allAttributesUpdate
                    ? "En cours..."
                    : "Mettre à jour"}
                </button>
              </>
            )}
          </td>
        )}
        {applicant.shouldDisplay("rights_opening_date") && (
          <td className="update-box">
            {applicant.newRightsOpeningDate && (
              <>
                {applicant.newRightsOpeningDate}
                <br />
                <button
                  type="submit"
                  className="btn btn-primary btn-blue btn-sm mt-2"
                  onClick={() => handleApplicantUpdate("rightsOpeningDate")}
                >
                  {isLoading.rightsOpeningDateUpdate || isLoading.allAttributesUpdate
                    ? "En cours..."
                    : "Mettre à jour"}
                </button>
              </>
            )}
          </td>
        )}
        <td>
          {[applicant.newEmail, applicant.newPhoneNumber, applicant.newRightsOpeningDate].filter(
            (e) => e != null
          ).length > 1 && (
            <button
              type="submit"
              className="btn btn-primary btn-blue"
              onClick={() => handleApplicantUpdate("allAttributes")}
            >
              {isLoading.emailUpdate ||
              isLoading.phoneNumberUpdate ||
              isLoading.rightsOpeningDateUpdate ||
              isLoading.allAttributesUpdate
                ? "En cours..."
                : "Tout mettre à jour"}
            </button>
          )}
        </td>
        <td colSpan={colSpanForDisabledInvitations} />
      </tr>
    </>
  );
}
