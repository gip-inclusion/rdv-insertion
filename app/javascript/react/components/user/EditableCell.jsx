import React, { useState } from "react";
import { observer } from "mobx-react-lite";
import Tippy from "@tippyjs/react";
import EditableTags from "./EditableTags";

function EditableCell({ user, cell, type, values, labelClassName = "", labelStyle = {} }) {
  const [isEditing, setIsEditing] = useState(false);
  const [isEditingTags, setIsEditingTags] = useState(false);

  // We use a derived state here to allow rollback if HTTP request fails
  const [value, setValue] = useState(user[cell] || "");

  const handleDoubleClick = () => {
    if (type === "tags") {
      setIsEditingTags(true);
      return;
    }

    if (isEditing) return;
    setIsEditing(true);
    setValue(user[cell]);
  };

  const handleBlur = async () => {
    if (type === "tags") return;

    setIsEditing(false);

    const success = await user.updateAttribute(cell, value);
    if (!success) setValue(user[cell]);
  };

  const onEnterKeyPress = (event) => {
    if (event.key === "Enter") {
      handleBlur();
    }
  };

  let input;
  let label = user[cell] || " - ";
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
          <option key={key} value={v} selected={value === v}>
            {key}
          </option>
        ))}
      </select>
    );
    label = <span>{values.find((el) => el.value === user[cell])?.key || " - "}</span>;
  } else if (type === "tags") {
    const userTags = user[cell].map(tag => tag.toLowerCase())
    const existingTags = values.filter((tag) => userTags.includes(tag.toLowerCase()));
    newTags = user[cell].filter((tag) => !values.map(v => v.toLowerCase()).includes(tag.toLowerCase()));

    label = (
      <div className="text-center w-100">
        {newTags.length ? (
          <div className="px-1 w-100 text-warning position-relative">
            {newTags.join(", ")}
            <i className="fas fa-exclamation-triangle icon-sm position-absolute mt-1 mx-1" />
          </div>
        ) : null}
        {existingTags.length ? <div className="px-1 w-100">{existingTags.join(", ")}</div> : null}
        {!newTags.length && !existingTags.length ? " - " : null}
      </div>
    );
  } else {
    label = (
      <div className={labelClassName} style={labelStyle} >
        {user[cell] || " - "}
      </div >
    );
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
    );
  }

  return (
    <Tippy
      delay={800}
      disabled={isEditing || isEditingTags}
      content={[
        newTags?.length
          ? "Les tags signalés en orange ne seront pas pris en compte, ils doivent d'abord être créés dans la configuration de l'organisation. "
          : "",
        user.triggers[`${cell}Update`] ? "En cours..." : "Double-cliquez pour modifier",
      ].join("")}
    >
      <div
        onDoubleClick={handleDoubleClick}
        onBlur={handleBlur}
        className="d-flex justify-content-center align-items-center"
        style={{ cursor: "pointer" }}
      >
        {isEditing ? input : label}
        {isEditingTags ? (
          <EditableTags
            user={user}
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
