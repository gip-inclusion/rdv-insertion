import React from "react";
import { observer } from "mobx-react-lite";
import handleCarnetCreation from "../../lib/handleCarnetCreation";

export default observer(({ user }) => {
  const handleClick = async () => {
    user.triggers.carnetCreation = true;
    await handleCarnetCreation(user);
    user.triggers.carnetCreation = false;
  };

  return user.carnet_de_bord_carnet_id ? (
      <a
        href={`${process.env.CARNET_DE_BORD_URL}/manager/carnets/${user.carnet_de_bord_carnet_id}`}
        target="_blank"
        rel="noreferrer"
      >
        <i className="ri-links-line" />
      </a>
    ) : (
      <button
        type="submit"
        disabled={user.triggers.carnetCreation || !user.createdAt}
        className="btn btn-primary btn-blue"
        onClick={() => handleClick()}
      >
        {user.triggers.carnetCreation ? "Création carnet..." : "Créer carnet"}
      </button>
  );
});
