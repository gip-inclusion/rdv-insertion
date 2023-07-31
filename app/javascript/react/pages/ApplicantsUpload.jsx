import React, { useState } from "react";
import Swal from "sweetalert2";
import Tippy from "@tippyjs/react";
import { observer } from "mobx-react-lite";

import * as XLSX from "xlsx";
import FileHandler from "../components/FileHandler";
import ApplicantList from "../components/ApplicantList";
import EnrichWithContactFile from "../components/EnrichWithContactFile";
import ApplicantBatchActions from "../components/ApplicantBatchActions";

import getHeaderNames from "../lib/getHeaderNames";
import checkColumnNames from "../lib/checkColumnNames";
import displayMissingColumnsWarning from "../lib/displayMissingColumnsWarning";
import retrieveUpToDateApplicants from "../lib/retrieveUpToDateApplicants";
import parseContactsData from "../lib/parseContactsData";
import updateApplicantContactsData from "../lib/updateApplicantContactsData";
import retrieveContactsData from "../lib/retrieveContactsData";
import { formatDateInput } from "../../lib/datesHelper";
import {
  parameterizeObjectKeys,
  parameterizeObjectValues,
  parameterizeArray,
} from "../../lib/parameterize";

import Applicant from "../models/Applicant";
import applicantsStore from "../models/Applicants";

const ApplicantsUpload = observer(({
  applicants,
  organisation,
  configuration,
  columnNames,
  sheetName,
  department,
  motifCategoryName,
  currentAgent,
}) => {
  const parameterizedColumnNames = parameterizeObjectValues({ ...columnNames });
  const isDepartmentLevel = !organisation;
  const [fileSize, setFileSize] = useState(0);
  /* eslint no-unused-vars: ["error", { "varsIgnorePattern": "contactsUpdated" }] */
  // This state allows to re-renders applicants after contacts update
  const [contactsUpdated, setContactsUpdated] = useState(false);
  const [showEnrichWithContactFile, setShowEnrichWithContactFile] = useState(false);
  const [showReferentColumn, setShowReferentColumn] = useState(
    configuration && configuration.rdv_with_referents
  );
  const showCarnetColumn = !!department.carnet_de_bord_deploiement_id;

  const redirectToApplicantList = () => {
    if (configuration) {
      window.location.href = isDepartmentLevel
        ? `/departments/${department.id}/applicants?motif_category_id=${configuration.motif_category_id}`
        : `/organisations/${organisation.id}/applicants?motif_category_id=${configuration.motif_category_id}`;
    } else {
      window.location.href = isDepartmentLevel
        ? `/departments/${department.id}/applicants`
        : `/organisations/${organisation.id}/applicants`;
    }
  };

  const retrieveApplicantsFromList = async (file) => {
    await new Promise((resolve) => {
      const reader = new FileReader();
      reader.onload = function (event) {
        const workbook = XLSX.read(event.target.result, { type: "binary" });
        const sheet = workbook.Sheets[sheetName] || workbook.Sheets[workbook.SheetNames[0]];
        const headerNames = getHeaderNames(sheet);
        const missingColumnNames = checkColumnNames(columnNames, parameterizeArray(headerNames));
        if (missingColumnNames.length > 0) {
          displayMissingColumnsWarning(missingColumnNames);
        } else {
          let rows = XLSX.utils.sheet_to_row_object_array(sheet);
          rows = rows.map((row) => parameterizeObjectKeys(row));
          rows.forEach((row) => {
            const applicant = new Applicant(
              // creation and editing to work properly
              {
                lastName: row[parameterizedColumnNames.last_name_column],
                firstName: row[parameterizedColumnNames.first_name_column],
                affiliationNumber: row[parameterizedColumnNames.affiliation_number_column],
                nir: row[parameterizedColumnNames.nir_column],
                poleEmploiId: row[parameterizedColumnNames.pole_emploi_id_column],
                role: row[parameterizedColumnNames.role_column],
                title: row[parameterizedColumnNames.title_column],
                addressFirstField:
                  parameterizedColumnNames.address_first_field_column &&
                  row[parameterizedColumnNames.address_first_field_column],
                addressSecondField:
                  parameterizedColumnNames.address_second_field_column &&
                  row[parameterizedColumnNames.address_second_field_column],
                addressThirdField:
                  parameterizedColumnNames.address_third_field_column &&
                  row[parameterizedColumnNames.address_third_field_column],
                addressFourthField:
                  parameterizedColumnNames.address_fourth_field_column &&
                  row[parameterizedColumnNames.address_fourth_field_column],
                addressFifthField:
                  parameterizedColumnNames.address_fifth_field_column &&
                  row[parameterizedColumnNames.address_fifth_field_column],
                email:
                  parameterizedColumnNames.email_column &&
                  row[parameterizedColumnNames.email_column],
                phoneNumber:
                  parameterizedColumnNames.phone_number_column &&
                  row[parameterizedColumnNames.phone_number_column],
                birthDate:
                  parameterizedColumnNames.birth_date_column &&
                  row[parameterizedColumnNames.birth_date_column] &&
                  formatDateInput(row[parameterizedColumnNames.birth_date_column]),
                birthName:
                  parameterizedColumnNames.birth_name_column &&
                  row[parameterizedColumnNames.birth_name_column],
                departmentInternalId:
                  parameterizedColumnNames.department_internal_id_column &&
                  row[parameterizedColumnNames.department_internal_id_column],
                rightsOpeningDate:
                  parameterizedColumnNames.rights_opening_date_column &&
                  row[parameterizedColumnNames.rights_opening_date_column] &&
                  formatDateInput(row[parameterizedColumnNames.rights_opening_date_column]),
                linkedOrganisationSearchTerms:
                  parameterizedColumnNames.organisation_search_terms_column &&
                  row[parameterizedColumnNames.organisation_search_terms_column],
                referentEmail:
                  parameterizedColumnNames.referent_email_column &&
                  row[parameterizedColumnNames.referent_email_column],
              },
              department,
              organisation,
              configuration,
              columnNames,
              currentAgent
            );
            applicants.addApplicant(applicant);
          });
        }
        resolve();
      };
      reader.readAsBinaryString(file);
    });
  };

  const isFormatValid = (file, acceptedFormats) => {
    if (acceptedFormats.some((format) => file.name.endsWith(format))) {
      return true;
    }
    return false;
  };

  const displayFormatErrorMessage = (acceptedFormats) => {
    Swal.fire({
      title: `Le fichier doit être au format ${acceptedFormats.map((format) => ` ${format}`)}`,
      icon: "error",
    });
  };

  const handleApplicantsFile = async (file) => {
    const acceptedFormats = [".csv", ".xls", ".xlsx", ".ods"];
    if (!isFormatValid(file, acceptedFormats)) {
      displayFormatErrorMessage(acceptedFormats);
      return;
    }

    setFileSize(file.size);
    applicants.setApplicants([])
    await retrieveApplicantsFromList(file);

    if (applicants.list.length === 0) return;

    applicants.setApplicants(await retrieveUpToDateApplicants(applicants.list, department.id));
  };

  const handleContactsFile = async (file) => {
    const acceptedFormats = [".csv", ".txt"];
    if (!isFormatValid(file, acceptedFormats)) {
      displayFormatErrorMessage(acceptedFormats);
      return;
    }

    setContactsUpdated(false);
    setFileSize(file.size);
    const contactsData = await retrieveContactsData(file);
    if (contactsData.length === 0) return;

    await Promise.all(
      applicants.list.map(async (applicant) => {
        const applicantContactsData = contactsData.find(
          (contactRow) =>
            // padStart is used because sometimes affiliation numbers are fetched with less than 7 letters
            contactRow.MATRICULE.toString()?.padStart(7, "0") ===
            applicant.affiliationNumber?.padStart(7, "0")
        );
        if (applicantContactsData) {
          const parsedApplicantContactsData = await parseContactsData(applicantContactsData);
          applicant = await updateApplicantContactsData(applicant, parsedApplicantContactsData);
        }
      })
    );
    setContactsUpdated(true);
  };

  return (
    <>
    <div className="container mt-5 mb-8">
      <div className="row card-white justify-content-center">
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
          {configuration && (
            <h6>
              ({motifCategoryName}
              {configuration.rdv_with_referents && " avec réferents"})
            </h6>
          )}

          <FileHandler
            handleFile={handleApplicantsFile}
            fileSize={fileSize}
            name="applicants-list-upload"
            accept="text/plain, .csv, application/vnd.openxmlformats-officedocument.spreadsheetml.sheet, application/vnd.ms-excel, application/vnd.oasis.opendocument.spreadsheet"
            multiple={false}
            uploadMessage={<span>Choisissez un fichier de nouveaux demandeurs</span>}
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
      {!showEnrichWithContactFile && applicants.list.length > 0 && (
        <div className="my-4 text-center">
          <button
            type="button"
            className="btn btn-blue-out"
            onClick={() => setShowEnrichWithContactFile(true)}
          >
            Enrichir avec des données de contacts CNAF
          </button>
        </div>
      )}
      {showEnrichWithContactFile && applicants.list.length > 0 && (
        <EnrichWithContactFile handleContactsFile={handleContactsFile} fileSize={fileSize} />
      )}
      {applicants.list.length > 0 && (
        <>
          <div className="row my-1" style={{ height: 50 }}>
            <div className="d-flex justify-content-end align-items-center">
              <ApplicantBatchActions isDepartmentLevel={isDepartmentLevel} applicants={applicants} />
              <i className="fas fa-user" />
              {showReferentColumn ? (
                <Tippy content="Cacher colonne référent">
                  <button type="button" onClick={() => setShowReferentColumn(false)}>
                    <i className="fas fa-minus" />
                  </button>
                </Tippy>
              ) : (
                <Tippy content="Montrer colonne référent">
                  <button type="button" onClick={() => setShowReferentColumn(true)}>
                    <i className="fas fa-plus" />
                  </button>
                </Tippy>
              )}
            </div>
          </div>
        </>
      )}
    </div>
    {applicants.list.length > 0 && (
      <>
        <div className="my-5 px-4" style={{ overflow: "scroll" }}>
          <table className="table table-hover text-center align-middle table-striped table-bordered">
            <thead className="align-middle dark-blue">
              <tr>
                <th scope="col" className="text-center">
                  Sélection
                  <br />
                  <input 
                    type="checkbox" 
                    className="form-check-input"
                    checked={applicants.list.every(applicant => applicant.selected)} 
                    onChange={event => applicants.list.forEach(applicant => { applicant.selected = event.target.checked })}
                    />
                </th>
                <th scope="col">Civilité</th>
                <th scope="col">Prénom</th>
                <th scope="col">Nom</th>
                {parameterizedColumnNames.affiliation_number_column && (
                  <th scope="col">Numéro allocataire</th>
                )}
                {parameterizedColumnNames.role_column && <th scope="col">Rôle</th>}
                {parameterizedColumnNames.department_internal_id_column && (
                  <th scope="col">ID Editeur</th>
                )}
                {parameterizedColumnNames.nir_column && <th scope="col">NIR</th>}
                {parameterizedColumnNames.pole_emploi_id_column && <th scope="col">ID PE</th>}
                {parameterizedColumnNames.email_column && <th scope="col">Email</th>}
                {parameterizedColumnNames.phone_number_column && <th scope="col">Téléphone</th>}
                {parameterizedColumnNames.rights_opening_date_column && (
                  <th scope="col">Date d&apos;entrée flux</th>
                )}
                <th scope="col" style={{ whiteSpace: "nowrap" }}>
                  Création compte
                </th>
                {showCarnetColumn && (
                  <th scope="col" style={{ whiteSpace: "nowrap" }}>
                    Création carnet
                  </th>
                )}
                {showReferentColumn && <th scope="col-3">Réferent</th>}
                {configuration && configuration.invitation_formats.includes("sms") && (
                  <th scope="col-3">Invitation SMS</th>
                )}
                {configuration && configuration.invitation_formats.includes("email") && (
                  <th scope="col-3">Invitation mail</th>
                )}
                {configuration && configuration.invitation_formats.includes("postal") && (
                  <th scope="col-3">Invitation courrier</th>
                )}
              </tr>
            </thead>
            <tbody>
              <ApplicantList
                showReferentColumn={showReferentColumn}
                applicants={applicants}
                isDepartmentLevel={isDepartmentLevel}
                showCarnetColumn={showCarnetColumn}
              />
            </tbody>
          </table>
        </div>
      </>
      )}
    </>
  );
})


export default (props) => (
  <ApplicantsUpload applicants={applicantsStore} {...props} />
)