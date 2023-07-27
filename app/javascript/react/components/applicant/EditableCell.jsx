import React, { useState } from "react";
import { observer } from "mobx-react-lite";
import Tippy from "@tippyjs/react";
import handleApplicantUpdate from "../../lib/handleApplicantUpdate";

function EditableCell({ applicant, cell }) {
  const [isEditing, setIsEditing] = useState(false);

  // We use a derived state here to allow rollback if HTTP request fails
  const [value, setValue] = useState(applicant[cell] || "");

  const handleDoubleClick = () => {
    setIsEditing(true);

  };

  const handleBlur = async () => {
    setIsEditing(false);

    const previousValue = applicant[cell];
    applicant[cell] = value;

    if (applicant.createdAt) {
      applicant.triggers[`${cell}Update`] = true;
      const result = await handleApplicantUpdate(applicant.currentOrganisation.id, applicant, applicant.asJson())

      if (!result.success) {
        applicant[cell] = previousValue;
        setValue(previousValue);
      }

      applicant.triggers[`${cell}Update`] = false;
    }
  };

  const onEnterKeyPress = (event) => {
    if (event.key === "Enter") {
      handleBlur();
    }
  };

  return (
    <Tippy
      delay={800}
      disabled={isEditing}
      content={applicant.triggers[`${cell}Update`] ? "En cours..." : "Double-cliquez pour modifier"}
    >
      <div
        onDoubleClick={handleDoubleClick}
        onBlur={handleBlur}
        style={{ cursor: "pointer" }}
      >

        {isEditing ? (
          <input
            type="text"
            // eslint-disable-next-line jsx-a11y/no-autofocus
            autoFocus
            value={value ?? ""}
            onKeyDown={onEnterKeyPress}
            onChange={(e) => setValue(e.target.value)}
          />
        ) : (
          <span>{value || " - "}</span>
        )}
      </div>
    </Tippy>
  );
}

export default observer(EditableCell);