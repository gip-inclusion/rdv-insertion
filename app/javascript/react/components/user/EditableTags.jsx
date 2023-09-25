import React from "react";
import { observer } from "mobx-react-lite";
import Tippy from "@tippyjs/react";

export default observer(({ user, cell, values, setIsEditingTags }) => {
  const addTag = () => {
    const newValue = document.getElementById("editable-tags").value;

    if (!newValue) return;
    user.updateAttribute(cell, [...user[cell], newValue]);
  };

  const removeTag = (tag) => {
    user.updateAttribute(cell, [...user[cell].filter((t) => t !== tag)]);
  };

  const availableValues = values.filter((value) => !user[cell].includes(value));

  return (
    <div className="modal d-block" style={{ backgroundColor: "rgba(0,0,0, 0.3)" }} role="dialog">
      <div className="modal-dialog" role="document">
        <div className="modal-content">
          <div className="modal-header">
            <h5 className="modal-title">Édition des Tags</h5>
            <button
              type="button"
              className="btn btn-blue-out"
              onClick={() => setIsEditingTags(false)}
            >
              Fermer
            </button>
          </div>
          <div className="modal-body d-flex flex-wrap">
            {availableValues.length && !user[cell].length
              ? "Choisissez un élement ci-dessous."
              : null}
            {!availableValues.length && !user[cell].length
              ? "Vous pouvez créer des tags depuis la configuration de l'organisation."
              : null}
            {user[cell].length
              ? user[cell].map((tag) => (
                  <Tippy
                    placement="top"
                    key={tag}
                    disabled={values.includes(tag)}
                    content="Ce tag ne sera pas pris en compte, il doit d'abord être créé dans la configuration de l'organisation."
                  >
                    <div
                      className={`badge w-auto d-flex justify-content-between bg-${
                        values.includes(tag) ? "primary" : "warning text-white"
                      } mb-1`}
                    >
                      {tag}
                      <button type="button" onClick={() => removeTag(tag)} className="text-white">
                        <i className="fas fa-minus icon-sm" />
                      </button>
                    </div>
                  </Tippy>
                ))
              : null}
          </div>
          <div className="modal-footer d-flex">
            {availableValues.length ? (
              <>
                <select id="editable-tags" className="form-control w-50">
                  <option value=""> Choisir un tag </option>
                  {availableValues.map((value) => (
                    <option key={value} value={value}>
                      {value}
                    </option>
                  ))}
                </select>
                <button type="button" onClick={addTag} className="btn btn-primary">
                  Ajouter
                </button>
              </>
            ) : (
              <p>
                Aucun {user[cell].length ? "autre" : ""} tag disponible pour cette organisation.
              </p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
});
