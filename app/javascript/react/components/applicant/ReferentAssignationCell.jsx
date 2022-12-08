import React, { useState } from "react";
import Swal from "sweetalert2";

import assignReferent from "../../actions/assignReferent";

export default function ReferentAssignationCell({ applicant, isTriggered, setIsTriggered }) {
  const [assignationDone, setAssignationDone] = useState(false);

  const handleReferentAssignationClick = async () => {
    setIsTriggered({ ...isTriggered, referentAssignation: true });

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
    setIsTriggered({ ...isTriggered, referentAssignation: false });
  };

  return (
    <>
      <td>
        {assignationDone || applicant.referentAlreadyAssigned() ? (
          <i className="fas fa-check" />
        ) : (
          <button
            type="submit"
            disabled={!applicant.createdAt || isTriggered.referentAssignation}
            className="btn btn-primary btn-blue"
            onClick={() => handleReferentAssignationClick()}
          >
            <small>
              {isTriggered.referentAssignation
                ? "Assignation..."
                : `Assigner ${applicant.referentEmail}`}
            </small>
          </button>
        )}
      </td>
    </>
  );
}
