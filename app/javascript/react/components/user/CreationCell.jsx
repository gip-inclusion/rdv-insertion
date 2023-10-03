import React from "react";
import { observer } from "mobx-react-lite";
import Tippy from "@tippyjs/react";

import handleArchiveDelete from "../../lib/handleArchiveDelete";

import { getFrenchFormatDateString } from "../../../lib/datesHelper";

export default observer(({ user }) => {
  const handleFileReopen = async () => {
    user.triggers.unarchive = true;

    await handleArchiveDelete(user);

    user.triggers.unarchive = false;
  };

  const handleCreationClick = async () => {
    user.createAccount();
  };

  if (user.errors.includes("createAccount")) {
    return (
      <td>
        <button type="submit" className="btn btn-danger" onClick={() => handleCreationClick()}>
          Résoudre les erreurs
        </button>
      </td>
    );
  }

  return user.isArchivedInCurrentDepartment() ? (
    <td>
      <button
        type="submit"
        disabled={user.triggers.unarchive}
        className="btn btn-primary btn-blue"
        onClick={() => handleFileReopen()}
      >
        Rouvrir le dossier
      </button>
    </td>
  ) : user.createdAt ? (
    !user.belongsToCurrentOrg() ? (
      <Tippy
        content={
          <span>
            Cet usager est déjà présent dans RDV-Insertion dans une autre organisation que
            l&apos;organisation actuelle.
            <br />
            Appuyez sur ce bouton pour ajouter l&apos;usager à cette organisation et mettre à jours
            ses informations.
          </span>
        }
      >
        <td>
          <button
            type="submit"
            disabled={user.triggers.creation}
            className="btn btn-primary btn-blue"
            onClick={() => handleCreationClick()}
          >
            {user.triggers.creation ? "En cours..." : "Ajouter à cette organisation"}
          </button>
        </td>
      </Tippy>
    ) : (
      <td>
        <a
          href={
            user.list.isDepartmentLevel
              ? `/departments/${user.department.id}/users/${user.id}`
              : `/organisations/${user.currentOrganisation.id}/users/${user.id}`
          }
          target="_blank"
          rel="noreferrer"
        >
          <Tippy
            content={
              <span>
                Compte créé le&nbsp;
                {getFrenchFormatDateString(user.createdAt)}
                <br />
                Vous pouvez consulter sa fiche en cliquant
              </span>
            }
          >
            <i className="fas fa-link" />
          </Tippy>
        </a>
      </td>
    )
  ) : (
    <td>
      <button
        type="submit"
        disabled={user.triggers.creation}
        className="btn btn-primary btn-blue"
        onClick={() => handleCreationClick()}
      >
        {user.triggers.creation ? "Création..." : "Créer compte"}
      </button>
    </td>
  );
});
