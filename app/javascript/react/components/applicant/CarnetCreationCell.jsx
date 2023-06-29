import React from "react";

import handleCarnetCreation from "../../lib/handleCarnetCreation";

export default function CarnetCreationCell({ applicant, isTriggered, setIsTriggered }) {
  const handleClick = async () => {
    setIsTriggered({ ...isTriggered, carnetCreation: true });
    await handleCarnetCreation(applicant);
    setIsTriggered({ ...isTriggered, carnetCreation: false });
  };

  return (
    <td>
      {applicant.carnet_de_bord_carnet_id ? (
        <i className="fas fa-check" />
      ) : (
        <button
          type="submit"
          disabled={isTriggered.carnetCreation || !applicant.createdAt}
          className="btn btn-primary btn-blue"
          onClick={() => handleClick()}
        >
          {isTriggered.carnetCreation ? "Création carnet..." : "Créer carnet"}
        </button>
      )}
    </td>
  );
}
