import React from "react";
import { observer } from "mobx-react-lite";

import handleUserUpdate from "../../lib/handleUserUpdate";
import camelToSnakeCase from "../../../lib/stringHelper";

export default observer(({ user }) => {
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

  return (
    <tr className="table-success">
      <td colSpan={user.list.numberOfColumnsBeforeContactListUpdate} className="text-align-right">
        <i className="ri-corner-right-up-fill" />
        Nouvelles données trouvées pour {user.firstName} {user.lastName}
      </td>
      {user.list.columnsAfterFirstContactListUpdate.map(
        (column) => column.visible && column.isInContactFile ?
          (
            <td
              className="update-box"
              key={`${column.key}${new Date().toISOString().slice(0, 19)}`}
            >
              {user[`${column.key}New`] && (
                <>
                  {user[`${column.key}New`]}
                  <br />
                  <button
                    type="submit"
                    className="btn btn-primary btn-blue btn-sm mt-2"
                    onClick={() => handleUpdateContactsDataClick(column.key)}
                  >
                    {user.triggers[`${column.key}Update`] || user.triggers.allAttributesUpdate
                      ? "En cours..."
                      : "Mettre à jour"}
                  </button>
                </>
              )}
            </td>
          ) : <td />)}
          
      <td>
        {user.list.columnsAfterFirstContactListUpdate.filter((column) => column.isInContactFile && user[`${column.key}New`] !== null)
          .length && (
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
    </tr>
  );
});
