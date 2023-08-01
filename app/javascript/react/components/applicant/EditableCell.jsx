import React, { useState } from "react";
import { observer } from "mobx-react-lite";
import Tippy from "@tippyjs/react";
import handleApplicantUpdate from "../../lib/handleApplicantUpdate";

function EditableCell({ applicant, cell, type, values }) {
  const [isEditing, setIsEditing] = useState(false);

  // We use a derived state here to allow rollback if HTTP request fails
  const [value, setValue] = useState(applicant[cell] || "");

  const handleDoubleClick = () => {
    if (isEditing) return;
    setIsEditing(true);
    setValue(applicant[cell]);
  };

  const handleBlur = async () => {
    setIsEditing(false);

    if (value === applicant[cell]) return;

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

  let input;
  let label = applicant[cell] || " - ";

  if (type === "select") {
    input = (
      <select
        type="text"
        autoFocus
        className="form-select"
        onKeyDown={onEnterKeyPress}
        onChange={(e) => setValue(e.target.value)}
        style={{ width: 90 }}
      >
        <option value=""> - </option>
        {values.map(({ key, value: v }) => (
          <option key={key} value={v} selected={value === v}>{key}</option>
        ))}
      </select>
   )
   label = values.find(el => el.value === applicant[cell])?.key || " - "
  } else {
    input = (
     <input
       type="text"
       autoFocus
       className="form-control"
       style={{ minWidth: 100 }}
       value={value ?? ""}
       onKeyDown={onEnterKeyPress}
       onChange={(e) => setValue(e.target.value)}
     />
   )
  }

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

        {isEditing ? input : ( <span>{label}</span> )}
      </div>
    </Tippy>
  );
}

export default observer(EditableCell);