import React from "react";
import { observer } from "mobx-react-lite";

export default observer(({ applicant, cell, values, setIsEditingMultiselect }) => {
  const addTag = () => {
    const newValue = document.getElementById("multiselect").value

    if (!newValue) return
    applicant[cell] = [...applicant[cell], newValue]
  }

  const removeTag = (tag) => {
    applicant[cell] = applicant[cell].filter((t) => t !== tag)
  }

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
            {applicant[cell].map((tag) => values.includes(tag) ? (
                <div key={tag} className="badge w-auto d-flex justify-content-between bg-primary mb-1">
                  {tag}
                  <button type="button" onClick={() => removeTag(tag)} className="text-white">
                    <i className="fas fa-minus icon-sm" />
                  </button>
                </div>
              ) : null)}
          </div>
          <div className="modal-footer d-flex">
            <select id="multiselect" className="form-control w-50" onChange={() => addTag()}>
              <option value=""> Choisir une option </option>
              {values.map((value) => applicant[cell].includes(value) ? null : (
                  <option key={value} value={value}>{value}</option>
                ))}
            </select>
            <button type="button" onClick={addTag} className="btn btn-primary">Ajouter</button>
          </div>
        </div>
      </div>
    </div>
  );
})
