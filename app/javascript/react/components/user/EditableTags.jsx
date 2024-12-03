import React, { useState } from "react";
import { observer } from "mobx-react-lite";

export default observer(({ user, cell, values, setIsEditingTags }) => {
  const [temporarySelection, setTemporarySelection] = useState([...user[cell]]);

  const addOrRemoveTagFromTemporarySelection = (tag) => {
    if (temporarySelection.includes(tag)) setTemporarySelection(temporarySelection.filter((t) => t !== tag))
    else setTemporarySelection([...temporarySelection, tag]);
  }

  const saveTemporarySelection = async () => {
    await user.updateAttribute(cell, temporarySelection);
    setIsEditingTags(false);
  };

  return (
    <div className="modal d-block" style={{ backgroundColor: "rgba(0,0,0, 0.3)" }} role="dialog">
      <div className="modal-dialog" role="document">
        <div className="modal-content">
          <div className="modal-header">
            <h5 className="modal-title">Modifier les tags</h5>
            <button
              type="button"
              onClick={() => setIsEditingTags(false)}
            >
              <i className="ri-close-line" />
            </button>
          </div>
          <div className="modal-body d-flex flex-column">
            {values.map(tag => (
              <div key={tag} className="tag-container text-start ms-3 mb-2">
                <input
                  type="checkbox"
                  className="form-check-input me-3"
                  name="selectedTags"
                  value={tag}
                  checked={temporarySelection.includes(tag)}
                  onChange={(e) => addOrRemoveTagFromTemporarySelection(e.target.value)}
                />
                <label htmlFor={tag}>{tag}</label>
              </div>
            ))}
          </div>
          <div className="modal-footer border-0 d-flex">
            <button type="button" className="btn btn-blue-out border-0" onClick={() => setIsEditingTags(false)}>
              Annuler
            </button>
            <button type="button" className="btn btn-blue" onClick={saveTemporarySelection}>
              Enregistrer
            </button>
          </div>
        </div>
      </div>
    </div>
  );
});
