import React, { useState } from "react";
import Swal from "sweetalert2";
import Tippy from "@tippyjs/react";

import handleApplicantUpdate from "../../lib/handleApplicantUpdate";
import camelToSnakeCase from "../../../lib/stringHelper";

export default function ContactInfosExtraLine({
  applicant,
  invitationsColspan,
  isTriggered,
  setIsTriggered,
}) {
  const handleUpdateContactsDataClick = async (attribute = null) => {
    setIsTriggered({ ...isTriggered, [`${attribute}Update`]: true });

    const attributes = {};
    if (attribute === "allAttributes") {
      attributes.email = applicant.emailNew;
      attributes.phone_number = applicant.phoneNumberNew;
      attributes.rights_opening_date = applicant.rightsOpeningDateNew;
    } else {
      attributes[`${camelToSnakeCase(attribute)}`] = applicant[`${attribute}New`];
    }

    const result = await handleApplicantUpdate(applicant, attributes);

    if (result.success) {
      if (attribute === "allAttributes") {
        applicant.markAttributeAsUpdated("email");
        applicant.markAttributeAsUpdated("phoneNumber");
        applicant.markAttributeAsUpdated("rightsOpeningDate");
      } else {
        applicant.markAttributeAsUpdated(`${attribute}`);
      }
    }

    setIsTriggered({ ...isTriggered, [`${attribute}Update`]: false });
  };

  const colSpanForContactsUpdate =
    applicant.displayedAttributes().length - applicant.attributesFromContactsDataFile().length;

  return (
    <tr className="table-success">
      <td colSpan={colSpanForContactsUpdate} className="text-align-right">
        <i className="fas fa-level-up-alt" />
        Nouvelles données trouvées pour {applicant.firstName} {applicant.lastName}
      </td>
      {["email", "phoneNumber", "rightsOpeningDate"].map(
        (attributeName) =>
          applicant.shouldDisplay(camelToSnakeCase(attributeName)) && (
            <td
              className="update-box"
              key={`${attributeName}${new Date().toISOString().slice(0, 19)}`}
            >
              {applicant[`${attributeName}New`] && (
                <>
                  {applicant[`${attributeName}New`]}
                  <br />
                  <button
                    type="submit"
                    className="btn btn-primary btn-blue btn-sm mt-2"
                    onClick={() => handleUpdateContactsDataClick(attributeName)}
                  >
                    {isTriggered[`${attributeName}Update`] || isTriggered.allAttributesUpdate
                      ? "En cours..."
                      : "Mettre à jour"}
                  </button>
                </>
              )}
            </td>
          )
      )}
      <td>
        {[applicant.emailNew, applicant.phoneNumberNew, applicant.rightsOpeningDateNew].filter(
          (e) => e != null
        ).length > 1 && (
          <button
            type="submit"
            className="btn btn-primary btn-blue"
            onClick={() => handleUpdateContactsDataClick("allAttributes")}
          >
            {isTriggered.emailUpdate ||
            isTriggered.phoneNumberUpdate ||
            isTriggered.rightsOpeningDateUpdate ||
            isTriggered.allAttributesUpdate
              ? "En cours..."
              : "Tout mettre à jour"}
          </button>
        )}
      </td>
      <td colSpan={invitationsColspan} />
    </tr>
  );
}
