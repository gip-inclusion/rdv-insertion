import React, { useState } from "react";
import { observer } from "mobx-react-lite";
import Tippy from "@tippyjs/react";
import EditableTags from "./EditableTags";

function EditableCell({ applicant, cell, type, values }) {
  const [isEditing, setIsEditing] = useState(false);
  const [isEditingTags, setIsEditingTags] = useState(false);

  // We use a derived state here to allow rollback if HTTP request fails
  const [value, setValue] = useState(applicant[cell] || "");

  const handleDoubleClick = () => {
    if (type === "tags") {
      setIsEditingTags(true);
      return;
    }

    if (isEditing) return;
    setIsEditing(true);
    setValue(applicant[cell]);
  };

  const handleBlur = async () => {
    if (type === "tags") return;

    setIsEditing(false);

    const success = await applicant.updateAttribute(cell, value);
    if (!success) setValue(applicant[cell]);
  };

  const onEnterKeyPress = (event) => {
    if (event.key === "Enter") {
      handleBlur();
    }
  };

  let input;
  let label = applicant[cell] || " - ";
  let newTags;

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
  } else if (type === "tags") {
    const existingTags = values.filter(tag => applicant[cell].includes(tag))
    newTags = applicant[cell].filter(tag => !values.includes(tag))

    label = (
      <div className="text-center w-100">
        {newTags.length ? (
          <div className="px-1 w-100 text-warning position-relative">
            {newTags.join(", ")}
            <i className="fas fa-exclamation-triangle icon-sm position-absolute mt-1 mx-1" />
          </div>
        ) : null}
        {existingTags.length ? (
          <div className="px-1 w-100">
            {existingTags.join(", ")}
          </div>
        ) : null
        }
        {!newTags.length && !existingTags.length ? " - " : null}
      </div>
    )
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
      disabled={isEditing || isEditingTags}
      content={[
        newTags?.length ? "Les catégories signalées en orange ne seront pas prises en compte, elle doivent d'abord être créées dans la configuration de l'organisation. " : "",
        applicant.triggers[`${cell}Update`] ? "En cours..." : "Double-cliquez pour modifier",
      ].join("")}
    >
      <div
        onDoubleClick={handleDoubleClick}
        onBlur={handleBlur}
        style={{ cursor: "pointer" }}
      >

        {isEditing ? input : ( <span>{label}</span> )}
        {isEditingTags ? (
          <EditableTags
            applicant={applicant}
            cell={cell}
            values={values}
            setIsEditingTags={setIsEditingTags}
          />
        ) : null}
      </div>
    </Tippy>
  );
}

export default observer(EditableCell);