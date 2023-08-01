import React, { useState } from "react";
import { observer } from "mobx-react-lite";
import Swal from "sweetalert2";

import assignReferent from "../../actions/assignReferent";

export default observer(({ applicant }) => {
  const [assignationDone, setAssignationDone] = useState(false);

  const handleReferentAssignationClick = async () => {
    applicant.triggers.referentAssignation = true;

    const result = await assignReferent(
      applicant.department.id,
      applicant.id,
      applicant.referentEmail
    );
    if (result.success) {
      setAssignationDone(true);
    } else {
      Swal.fire(
        `Impossible d'assigner le référent ${applicant.referentEmail}`,
        result.errors[0],
        "error"
      );
    }
    applicant.triggers.referentAssignation = false;
  };

  return (
    <>
      <td>
        {assignationDone || applicant.referentAlreadyAssigned() ? (
          <i className="fas fa-check" />
        ) : (
          <button
            type="submit"
            disabled={!applicant.createdAt || applicant.triggers.referentAssignation}
            className="btn btn-primary btn-blue"
            onClick={() => handleReferentAssignationClick()}
          >
            <small>
              {applicant.triggers.referentAssignation
                ? "Assignation..."
                : `Assigner ${applicant.referentEmail}`}
            </small>
          </button>
        )}
      </td>
    </>
  );
});
