import React from "react";
import { observer } from "mobx-react-lite";

import handleApplicantUpdate from "../../lib/handleApplicantUpdate";
import camelToSnakeCase from "../../../lib/stringHelper";

export default observer(({
  applicant,
  invitationsColspan,
}) => {
  const handleUpdateContactsDataClick = async (attribute = null) => {
    applicant.triggers[`${attribute}Update`] = true;

    const attributes = {};
    if (attribute === "allAttributes") {
      attributes.email = applicant.emailNew;
      attributes.phone_number = applicant.phoneNumberNew;
      attributes.rights_opening_date = applicant.rightsOpeningDateNew;
    } else {
      attributes[`${camelToSnakeCase(attribute)}`] = applicant[`${attribute}New`];
    }

    const result = await handleApplicantUpdate(
      applicant.currentOrganisation.id,
      applicant,
      attributes
    );

    if (result.success) {
      if (attribute === "allAttributes") {
        applicant.markAttributeAsUpdated("email");
        applicant.markAttributeAsUpdated("phoneNumber");
        applicant.markAttributeAsUpdated("rightsOpeningDate");
      } else {
        applicant.markAttributeAsUpdated(`${attribute}`);
      }
    }

    applicant.triggers[`${attribute}Update`] = false;
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
          applicant.shouldDisplay(`${camelToSnakeCase(attributeName)}_column`) && (
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
                    {applicant.triggers[`${attributeName}Update`] || applicant.triggers.allAttributesUpdate
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
            {applicant.triggers.emailUpdate ||
            applicant.triggers.phoneNumberUpdate ||
            applicant.triggers.rightsOpeningDateUpdate ||
            applicant.triggers.allAttributesUpdate
              ? "En cours..."
              : "Tout mettre à jour"}
          </button>
        )}
      </td>
      <td colSpan={invitationsColspan} />
    </tr>
  );
})
