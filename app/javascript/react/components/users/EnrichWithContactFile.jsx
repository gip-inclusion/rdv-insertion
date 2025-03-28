import React from "react";
import Tippy from "@tippyjs/react";
import FileHandler from "../FileHandler";

export default function EnrichWithContactFile({ handleContactsFile, fileSize }) {
  return (
    <>
      <div className="row my-4 justify-content-center">
        <div className="col-4" />
        <div className="col-4 card-white text-center d-flex flex-column align-items-center">
          <div className="d-flex align-items-center">
            <h3 className="new-users-title">Ajout données de contacts</h3>
            <Tippy
              placement="right"
              content={
                <span>
                  Les informations de contact ne sont pas ajoutées aux usagers déjà créés.
                </span>
              }
            >
              <small className="d-inline-block mx-2">
                <i className="ri-alert-line" />
              </small>
            </Tippy>
          </div>
          <FileHandler
            handleFile={handleContactsFile}
            fileSize={fileSize}
            accept=".csv, text/plain"
            multiple={false}
            name="contact-file-upload"
            uploadMessage={
              <span>
                Choisissez un fichier de données de contact CNAF
                <br />
                (.csv, .txt)
              </span>
            }
            pendingMessage="Récupération des informations, merci de patienter"
          />
          <p className="mt-3 mb-0">
            <a
              href="https://resana.numerique.gouv.fr/public/information/consulterAccessUrl?cle_url=1564704891UjgFZVdbAj5QPVcxVjgHJwQ6XmNVdAJrDGcHOgZnW2EGN1VjUjFVMldjATdQYA=="
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
