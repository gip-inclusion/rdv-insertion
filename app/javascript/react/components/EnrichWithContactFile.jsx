import React from "react";
import Tippy from "@tippyjs/react";
import FileHandler from "./FileHandler";

export default function EnrichWithContactFile({ handleContactsFile, fileSize }) {
  return (
    <>
      <div className="row my-4 justify-content-center">
        <div className="col-4" />
        <div className="col-4 block-white text-center d-flex flex-column align-items-center">
          <div className="d-flex align-items-center">
            <h3 className="new-applicants-title">Ajout données de contacts</h3>
            <Tippy
              placement="right"
              content={
                <span>
                  Les informations de contact ne sont pas ajoutées aux utilisateurs déjà créés.
                </span>
              }
            >
              <small className="d-inline-block mx-2">
                <i className="fas fa-exclamation-triangle" />
              </small>
            </Tippy>
          </div>
          <FileHandler
            handleFile={handleContactsFile}
            fileSize={fileSize}
            multiple={false}
            uploadMessage="Choisissez un fichier de données de contact CNAF"
            pendingMessage="Récupération des informations, merci de patienter"
          />
          <p className="mt-3 mb-0">
            <a
              href="https://forum.inclusion.beta.gouv.fr/t/communication-aux-departements-des-coordonnees-de-contact-des-beneficiaires-rsa-mise-a-disposition-hebdomadaire/7112"
              target="_blank"
              rel="noreferrer"
            >
              Comment obtenir ce fichier ?
            </a>
          </p>
        </div>
        <div className="col-4" />
      </div>
    </>
  );
}
