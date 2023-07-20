import React from "react";
import { observer } from "mobx-react-lite";
import handleCarnetCreation from "../../lib/handleCarnetCreation";

export default observer(({ applicant }) => {
  const handleClick = async () => {
    applicant.triggers.carnetCreation = true;
    await handleCarnetCreation(applicant);
    applicant.triggers.carnetCreation = false;
  };

  return (
    <td>
      {applicant.carnet_de_bord_carnet_id ? (
        <a
          href={`${process.env.CARNET_DE_BORD_URL}/manager/carnets/${applicant.carnet_de_bord_carnet_id}`}
          target="_blank"
          rel="noreferrer"
        >
          <i className="fas fa-link" />
        </a>
      ) : (
        <button
          type="submit"
          disabled={applicant.triggers.carnetCreation || !applicant.createdAt}
          className="btn btn-primary btn-blue"
          onClick={() => handleClick()}
        >
          {applicant.triggers.carnetCreation ? "Création carnet..." : "Créer carnet"}
        </button>
      )}
    </td>
  );
})
