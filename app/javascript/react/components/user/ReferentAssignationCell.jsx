import React from "react";
import { observer } from "mobx-react-lite";
import Tippy from "@tippyjs/react";

export default observer(({ user }) => {
  const handleReferentAssignationClick = async () => {
    user.assignReferent();
  };

  return (
    user.referentAlreadyAssigned() ? (
      <Tippy
        content={`Référent: ${user.referentFullName()}`}
      >
        <i className="ri-check-line" />
      </Tippy>
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
    )
  );
});
