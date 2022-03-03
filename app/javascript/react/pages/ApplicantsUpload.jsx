import React, { useState, useReducer } from "react";

import FileHandler from "../components/FileHandler";
import ApplicantList from "../components/ApplicantList";
import EnrichWithContactFile from "../components/EnrichWithContactFile";

import { parameterizeObjectValues } from "../../lib/parameterize";
import retrieveApplicantsFromList from "../lib/retrieveApplicantsFromList";
import retrieveUpToDateApplicants from "../lib/retrieveUpToDateApplicants";
import updateApplicantContacts from "../lib/updateApplicantContacts";
import retrieveContactsData from "../lib/retrieveContactsData";
import { initReducer, reducerFactory } from "../../lib/reducers";

const reducer = reducerFactory("Expérimentation RSA");

export default function ApplicantsUpload({ organisation, configuration, department }) {
  const columnNames = configuration.column_names;
  const parameterizedColumnNames = parameterizeObjectValues({
    ...columnNames.required,
    ...columnNames.optional,
  });
  const isDepartmentLevel = !organisation;

  const [fileSize, setFileSize] = useState(0);
  /* eslint no-unused-vars: ["error", { "varsIgnorePattern": "contactsUpdated" }] */
  // This state allows to re-renders applicants after contacts update
  const [contactsUpdated, setContactsUpdated] = useState(false);
  const [downloadInProgress, setDownloadInProgress] = useState(false);
  const [showEnrichWithContactFile, setShowEnrichWithContactFile] = useState(false);
  const [applicants, dispatchApplicants] = useReducer(reducer, [], initReducer);

  const redirectToApplicantList = () => {
    window.location.href = isDepartmentLevel
      ? `/departments/${department.id}/applicants`
      : `/organisations/${organisation.id}/applicants`;
  };

  const handleApplicantsFile = async (file) => {
    setFileSize(file.size);

    dispatchApplicants({ type: "reset" });
    const applicantsFromList = await retrieveApplicantsFromList(
      file,
      organisation,
      department,
      configuration,
      columnNames,
      parameterizedColumnNames
    );
    if (applicantsFromList.length === 0) return;

    const upToDateApplicants = await retrieveUpToDateApplicants(applicantsFromList);

    upToDateApplicants.forEach((applicant) => {
      dispatchApplicants({
        type: "append",
        item: {
          applicant,
          seed: applicant.uid,
        },
      });
    });
  };

  const handleContactsFile = async (file) => {
    setContactsUpdated(false);
    setFileSize(file.size);
    const contactsData = await retrieveContactsData(file);
    if (contactsData.length === 0) return;

    await Promise.all(
      applicants.map(async (e) => {
        let { applicant } = e;
        const applicantContactsData = contactsData.find(
          (a) => a.MATRICULE.toString() === applicant.affiliationNumber
        );
        // if the applicant exists in DB, we don't update the record
        if (applicantContactsData && !applicant.createdAt) {
          applicant = await updateApplicantContacts(applicant, applicantContactsData);
        }
      })
    );
    setContactsUpdated(true);
  };

  return (
    <div className="container mt-5 mb-8">
      <div className="row block-white justify-content-center">
        <div className="col-4 text-center d-flex align-items-center justify-content-start">
          <button
            type="submit"
            className="btn btn-secondary btn-blue-out"
            onClick={() => redirectToApplicantList()}
          >
            Retour au suivi
          </button>
        </div>
        <div className="col-4 text-center d-flex flex-column align-items-center">
          <h3 className="new-applicants-title">
            Ajout {isDepartmentLevel ? "au niveau du territoire" : "allocataires"}
          </h3>
          <FileHandler
            handleFile={handleApplicantsFile}
            fileSize={fileSize}
            accept="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, application/vnd.ms-excel"
            multiple={false}
            uploadMessage={
              <span>
                Choisissez un fichier de nouveaux demandeurs
                <br />
                (.xls, xlsx)
              </span>
            }
            pendingMessage="Récupération des informations, merci de patienter"
          />
        </div>
        <div className="col-4 d-flex align-items-center justify-content-end">
          <a
            target="blank"
            href="https://rdv-insertion.gitbook.io/guide-dutilisation-rdv-insertion/"
          >
            <button type="button" className="btn btn-blue-out">
              Guide d&apos;utilisation
              <i className="fas fa-external-link-alt icon-sm" />
            </button>
          </a>
        </div>
      </div>
      {!showEnrichWithContactFile && applicants.length > 0 && (
        <div className="my-4 text-center">
          <button
            type="button"
            className="btn btn-blue-out"
            onClick={() => setShowEnrichWithContactFile(true)}
          >
            Enrichir avec données de contacts
          </button>
        </div>
      )}
      {showEnrichWithContactFile && applicants.length > 0 && (
        <EnrichWithContactFile handleContactsFile={handleContactsFile} fileSize={fileSize} />
      )}
      {applicants.length > 0 && (
        <>
          <div className="row my-5 justify-content-center">
            <table className="table table-hover text-center align-middle table-striped table-bordered">
              <thead className="align-middle dark-blue">
                <tr>
                  <th scope="col">Numéro allocataire</th>
                  <th scope="col">Civilité</th>
                  <th scope="col">Prénom</th>
                  <th scope="col">Nom</th>
                  <th scope="col">Rôle</th>
                  {parameterizedColumnNames.birth_date && <th scope="col">Date de naissance</th>}
                  {parameterizedColumnNames.email && <th scope="col">Email</th>}
                  {parameterizedColumnNames.phone_number && <th scope="col">Téléphone</th>}
                  {parameterizedColumnNames.department_internal_id && (
                    <th scope="col">ID Editeur</th>
                  )}
                  {parameterizedColumnNames.rights_opening_date && (
                    <th scope="col">Date d&apos;entrée flux</th>
                  )}
                  <th scope="col" style={{ whiteSpace: "nowrap" }}>
                    Création compte
                  </th>
                  {configuration.invitation_formats.includes("sms") && (
                    <>
                      <th scope="col-3">Invitation SMS</th>
                    </>
                  )}
                  {configuration.invitation_formats.includes("email") && (
                    <>
                      <th scope="col-3">Invitation mail</th>
                    </>
                  )}
                  {configuration.invitation_formats.includes("postal") && (
                    <>
                      <th scope="col-3">Invitation courrier</th>
                    </>
                  )}
                </tr>
              </thead>
              <tbody>
                <ApplicantList
                  applicants={applicants}
                  dispatchApplicants={dispatchApplicants}
                  isDepartmentLevel={isDepartmentLevel}
                  downloadInProgress={downloadInProgress}
                  setDownloadInProgress={setDownloadInProgress}
                />
              </tbody>
            </table>
          </div>
        </>
      )}
    </div>
  );
}
