import React, { useState } from "react";
import { observer } from "mobx-react-lite";
import Tippy from "@tippyjs/react";
import handleApplicantUpdate from "../../lib/handleApplicantUpdate";

function EditableCell({ applicant, cell }) {
  const [isEditing, setIsEditing] = useState(false);

  const handleDoubleClick = () => {
    setIsEditing(true);

  };

  const handleBlur = async () => {
    setIsEditing(false);
    if (applicant.createdAt) {
      applicant.triggers[`${cell}Update`] = true;
      await handleApplicantUpdate(applicant.currentOrganisation.id, applicant, applicant.asJson())
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
            value={applicant[cell] ?? ""}
            onKeyDown={onEnterKeyPress}
            onChange={(e) => { applicant[cell] = e.target.value }}
          />
        ) : (
          <span>{applicant[cell] || " - "}</span>
        )}
      </div>
    </Tippy>
  );
}

export default observer(EditableCell);