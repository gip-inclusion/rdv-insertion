import React from "react";
import { observer } from "mobx-react-lite";
import Tippy from "@tippyjs/react";

export default observer(({ applicant, cell, values, setIsEditingMultiselect }) => {
  const addTag = () => {
    const newValue = document.getElementById("multiselect").value

    if (!newValue) return
    applicant.updateAttribute(cell, [...applicant[cell], newValue])
  }

  const removeTag = (tag) => {
    applicant.updateAttribute(cell, [
      ...applicant[cell].filter((t) => t !== tag)
    ])
  }

  const availableValues = values.filter((value) => !applicant[cell].includes(value))

  return (
    <div className="modal d-block" style={{ backgroundColor: "rgba(0,0,0, 0.3)"}} role="dialog">
      <div className="modal-dialog" role="document">
        <div className="modal-content">
          <div className="modal-header">
            <h5 className="modal-title">Édition des {cell}</h5>
            <button type="button" className="btn btn-blue-out" onClick={() => setIsEditingMultiselect(false)}>
              Fermer
            </button>
          </div>
          <div className="modal-body d-flex flex-wrap">
            {availableValues.length && !applicant[cell].length ? "Choisissez un élement ci-dessous." : null}
            {!availableValues.length && !applicant[cell].length ? "Vous pouvez créer des catégories depuis la configuration de l'organisation." : null}
            {applicant[cell].length ? applicant[cell].map((tag) => (
              <Tippy
                placement="top"
                key={tag} 
                disabled={values.includes(tag)}
                content="Cette catégorie ne sera pas prise en compte, elle doit d'abord être créée dans la configuration de l'organisation."
              >
                <div className={`badge w-auto d-flex justify-content-between bg-${values.includes(tag) ? "primary" : "warning text-white"} mb-1`}>
                  {tag}
                  <button type="button" onClick={() => removeTag(tag)} className="text-white">
                    <i className="fas fa-minus icon-sm" />
                  </button>
                </div>
              </Tippy>
              )) : null}
          </div>
          <div className="modal-footer d-flex">
            {availableValues.length ? (
              <>
                <select id="multiselect" className="form-control w-50">
                  <option value=""> Choisir une catégorie </option>
                  {availableValues.map(value => (
                      <option key={value} value={value}>{value}</option>
                    ))}
                </select>
                <button type="button" onClick={addTag} className="btn btn-primary">Ajouter</button>
              </>
            ) : <p>Aucune {applicant[cell].length ? "autre" : ""} catégorie disponible pour cette organisation.</p>
            }
          </div>
        </div>
      </div>
    </div>
  );
})
