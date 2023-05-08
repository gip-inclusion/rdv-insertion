import React, { useState } from "react";
import Swal from "sweetalert2";
import Tippy from "@tippyjs/react";

import * as XLSX from "xlsx";
import FileHandler from "../components/FileHandler";
import ApplicantList from "../components/ApplicantList";
import EnrichWithContactFile from "../components/EnrichWithContactFile";

import getHeaderNames from "../lib/getHeaderNames";
import checkColumnNames from "../lib/checkColumnNames";
import displayMissingColumnsWarning from "../lib/displayMissingColumnsWarning";
import retrieveUpToDateApplicants from "../lib/retrieveUpToDateApplicants";
import parseContactsData from "../lib/parseContactsData";
import updateApplicantContactsData from "../lib/updateApplicantContactsData";
import retrieveContactsData from "../lib/retrieveContactsData";
import { excelDateToString } from "../../lib/datesHelper";
import {
  parameterizeObjectKeys,
  parameterizeObjectValues,
  parameterizeArray,
} from "../../lib/parameterize";

import Applicant from "../models/Applicant";

export default function ApplicantsUpload({
  organisation,
  configuration,
  columnNames,
  sheetName,
  department,
  motifCategoryName,
  currentAgent,
}) {
  const parameterizedColumnNames = parameterizeObjectValues({ ...columnNames });
  const isDepartmentLevel = !organisation;
  const [applicants, setApplicants] = useState([]);
  const [fileSize, setFileSize] = useState(0);
  /* eslint no-unused-vars: ["error", { "varsIgnorePattern": "contactsUpdated" }] */
  // This state allows to re-renders applicants after contacts update
  const [contactsUpdated, setContactsUpdated] = useState(false);
  const [showEnrichWithContactFile, setShowEnrichWithContactFile] = useState(false);
  const [showReferentColumn, setShowReferentColumn] = useState(configuration.rdv_with_referents);

  const redirectToApplicantList = () => {
    window.location.href = isDepartmentLevel
      ? `/departments/${department.id}/applicants?motif_category_id=${configuration.motif_category_id}`
      : `/organisations/${organisation.id}/applicants?motif_category_id=${configuration.motif_category_id}`;
  };

  const retrieveApplicantsFromList = async (file) => {
    const applicantsFromList = [];

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
                // address is street name and street number
                address:
                  parameterizedColumnNames.address_column &&
                  row[parameterizedColumnNames.address_column],
                // sometimes street number is separated from address
                streetNumber:
                  parameterizedColumnNames.street_number_column &&
                  row[parameterizedColumnNames.street_number_column],
                // sometimes street type is separated from address
                streetType:
                  parameterizedColumnNames.street_type_column &&
                  row[parameterizedColumnNames.street_type_column],
                // fullAddress is address with postal code and city
                fullAddress:
                  parameterizedColumnNames.full_address_column &&
                  row[parameterizedColumnNames.full_address_column],
                email:
                  parameterizedColumnNames.email_column &&
                  row[parameterizedColumnNames.email_column],
                birthDate:
                  parameterizedColumnNames.birth_date_column &&
                  row[parameterizedColumnNames.birth_date_column] &&
                  excelDateToString(row[parameterizedColumnNames.birth_date_column]),
                city:
                  parameterizedColumnNames.city_column && row[parameterizedColumnNames.city_column],
                postalCode:
                  parameterizedColumnNames.postal_code_column &&
                  row[parameterizedColumnNames.postal_code_column],
                phoneNumber:
                  parameterizedColumnNames.phone_number_column &&
                  row[parameterizedColumnNames.phone_number_column],
                birthName:
                  parameterizedColumnNames.birth_name_column &&
                  row[parameterizedColumnNames.birth_name_column],
                departmentInternalId:
                  parameterizedColumnNames.department_internal_id_column &&
                  row[parameterizedColumnNames.department_internal_id_column],
                rightsOpeningDate:
                  parameterizedColumnNames.rights_opening_date_column &&
                  row[parameterizedColumnNames.rights_opening_date_column] &&
                  excelDateToString(row[parameterizedColumnNames.rights_opening_date_column]),
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
            applicantsFromList.push(applicant);
          });
        }
        resolve();
      };
      reader.readAsBinaryString(file);
    });

    return applicantsFromList;
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
    const applicantsFromList = await retrieveApplicantsFromList(file);
    if (applicantsFromList.length === 0) return;

    const upToDateApplicants = await retrieveUpToDateApplicants(applicantsFromList, department.id);

    setApplicants(upToDateApplicants);
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
      applicants.map(async (applicant) => {
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
          <h6>
            ({motifCategoryName}
            {configuration.rdv_with_referents && " avec réferents"})
          </h6>

          <FileHandler
            handleFile={handleApplicantsFile}
            fileSize={fileSize}
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
      {!showEnrichWithContactFile && applicants.length > 0 && (
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
      {showEnrichWithContactFile && applicants.length > 0 && (
        <EnrichWithContactFile handleContactsFile={handleContactsFile} fileSize={fileSize} />
      )}
      {applicants.length > 0 && (
        <>
          <div className="row my-1">
            <div className="d-flex justify-content-end align-items-center">
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
      {applicants.length > 0 && (
        <>
          <div className="row my-5 justify-content-center">
            <table className="table table-hover text-center align-middle table-striped table-bordered">
              <thead className="align-middle dark-blue">
                <tr>
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
                  {parameterizedColumnNames.email_column && <th scope="col">Email</th>}
                  {parameterizedColumnNames.phone_number_column && <th scope="col">Téléphone</th>}
                  {parameterizedColumnNames.rights_opening_date_column && (
                    <th scope="col">Date d&apos;entrée flux</th>
                  )}
                  {parameterizedColumnNames.nir_column && <th scope="col">NIR</th>}
                  {parameterizedColumnNames.pole_emploi_id_column && <th scope="col">ID PE</th>}
                  <th scope="col" style={{ whiteSpace: "nowrap" }}>
                    Création compte
                  </th>
                  {showReferentColumn && (
                    <>
                      <th scope="col-3">Réferent</th>
                    </>
                  )}
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
                  showReferentColumn={showReferentColumn}
                  applicants={applicants}
                  isDepartmentLevel={isDepartmentLevel}
                />
              </tbody>
            </table>
          </div>
        </>
      )}
    </div>
  );
}
