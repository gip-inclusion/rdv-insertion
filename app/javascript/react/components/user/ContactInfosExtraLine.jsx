import React from "react";
import { observer } from "mobx-react-lite";

import handleUserUpdate from "../../lib/handleUserUpdate";
import camelToSnakeCase from "../../../lib/stringHelper";

export default observer(({ user, invitationsColspan }) => {
  const handleUpdateContactsDataClick = async (attribute = null) => {
    user.triggers[`${attribute}Update`] = true;

    const attributes = {};
    if (attribute === "allAttributes") {
      attributes.email = user.emailNew;
      attributes.phone_number = user.phoneNumberNew;
      attributes.rights_opening_date = user.rightsOpeningDateNew;
    } else {
      attributes[`${camelToSnakeCase(attribute)}`] = user[`${attribute}New`];
    }

    const result = await handleUserUpdate(user.currentOrganisation.id, user, attributes);

    if (result.success) {
      if (attribute === "allAttributes") {
        user.markAttributeAsUpdated("email");
        user.markAttributeAsUpdated("phoneNumber");
        user.markAttributeAsUpdated("rightsOpeningDate");
      } else {
        user.markAttributeAsUpdated(`${attribute}`);
      }
    }

    user.triggers[`${attribute}Update`] = false;
  };

  // We need to add 1 to the colSpan offset because of the multiple selection checkbox
  const colSpanForContactsUpdate =
    user.displayedAttributes().length - user.attributesFromContactsDataFile().length + 1;

  return (
    <tr className="table-success">
      <td colSpan={colSpanForContactsUpdate} className="text-align-right">
        <i className="fas fa-level-up-alt" />
        Nouvelles données trouvées pour {user.firstName} {user.lastName}
      </td>
      {["email", "phoneNumber", "rightsOpeningDate"].map(
        (attributeName) =>
          user.shouldDisplay(`${camelToSnakeCase(attributeName)}_column`) && (
            <td
              className="update-box"
              key={`${attributeName}${new Date().toISOString().slice(0, 19)}`}
            >
              {user[`${attributeName}New`] && (
                <>
                  {user[`${attributeName}New`]}
                  <br />
                  <button
                    type="submit"
                    className="btn btn-primary btn-blue btn-sm mt-2"
                    onClick={() => handleUpdateContactsDataClick(attributeName)}
                  >
                    {user.triggers[`${attributeName}Update`] || user.triggers.allAttributesUpdate
                      ? "En cours..."
                      : "Mettre à jour"}
                  </button>
                </>
              )}
            </td>
          )
      )}
      <td>
        {[user.emailNew, user.phoneNumberNew, user.rightsOpeningDateNew].filter((e) => e != null)
          .length > 1 && (
          <button
            type="submit"
            className="btn btn-primary btn-blue"
            onClick={() => handleUpdateContactsDataClick("allAttributes")}
          >
            {user.triggers.emailUpdate ||
            user.triggers.phoneNumberUpdate ||
            user.triggers.rightsOpeningDateUpdate ||
            user.triggers.allAttributesUpdate
              ? "En cours..."
              : "Tout mettre à jour"}
          </button>
        )}
      </td>
      <td colSpan={invitationsColspan} />
    </tr>
  );
});
