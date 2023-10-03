import React, { useState } from "react";
import { observer } from "mobx-react-lite";
import Swal from "sweetalert2";

import assignReferent from "../../actions/assignReferent";

export default observer(({ user }) => {
  const [assignationDone, setAssignationDone] = useState(false);

  const handleReferentAssignationClick = async () => {
    user.triggers.referentAssignation = true;

    const result = await assignReferent(user.department.id, user.id, user.referentEmail);
    if (result.success) {
      setAssignationDone(true);
    } else {
      Swal.fire(
        `Impossible d'assigner le référent ${user.referentEmail}`,
        result.errors[0],
        "error"
      );
    }
    user.triggers.referentAssignation = false;
  };

  return (
    <>
      {assignationDone || user.referentAlreadyAssigned() ? (
        <i className="fas fa-check" />
      ) : (
        <button
          type="submit"
          disabled={!user.createdAt || user.triggers.referentAssignation}
          className="btn btn-primary btn-blue"
          onClick={() => handleReferentAssignationClick()}
        >
          <small>
            {user.triggers.referentAssignation
              ? "Assignation..."
              : `Assigner ${user.referentEmail}`}
          </small>
        </button>
      )}
    </>
  );
});
