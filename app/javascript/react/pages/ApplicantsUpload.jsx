import React, { useState, useReducer } from "react";
import Swal from "sweetalert2";

import * as XLSX from "xlsx";
import FileHandler from "../components/FileHandler";
import ApplicantList from "../components/ApplicantList";
import EnrichWithContactFile from "../components/EnrichWithContactFile";

import getHeaderNames from "../lib/getHeaderNames";
import checkColumnNames from "../lib/checkColumnNames";
import displayMissingColumnsWarning from "../lib/displayMissingColumnsWarning";
import retrieveUpToDateApplicants from "../lib/retrieveUpToDateApplicants";
import updateApplicantContactsData from "../lib/updateApplicantContactsData";
import retrieveContactsData from "../lib/retrieveContactsData";
import { initReducer, reducerFactory } from "../../lib/reducers";
import { excelDateToString } from "../../lib/datesHelper";
import {
  parameterizeObjectKeys,
  parameterizeObjectValues,
  parameterizeArray,
} from "../../lib/parameterize";

import Applicant from "../models/Applicant";

const reducer = reducerFactory("Expérimentation RSA");

export default function ApplicantsUpload({ organisation, configuration, department, contextName }) {
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

  const retrieveApplicantsFromList = async (file) => {
    const applicantsFromList = [];

    await new Promise((resolve) => {
      const reader = new FileReader();
      reader.onload = function (event) {
        const sheetName = configuration.sheet_name;
        const workbook = XLSX.read(event.target.result, { type: "binary" });
        const sheet = workbook.Sheets[sheetName] || workbook.Sheets[workbook.SheetNames[0]];
        const headerNames = getHeaderNames(sheet);
        const missingColumnNames = checkColumnNames(
          columnNames,
          configuration,
          parameterizeArray(headerNames)
        );
        if (missingColumnNames.length > 0) {
          displayMissingColumnsWarning(missingColumnNames);
        } else {
          let rows = XLSX.utils.sheet_to_row_object_array(sheet);
          rows = rows.map((row) => parameterizeObjectKeys(row));
          rows.forEach((row) => {
            const applicant = new Applicant(
              {
                lastName: row[parameterizedColumnNames.last_name],
                firstName: row[parameterizedColumnNames.first_name],
                affiliationNumber: row[parameterizedColumnNames.affiliation_number],
                role: row[parameterizedColumnNames.role],
                title: row[parameterizedColumnNames.title],
                // address is street name and street number
                address: parameterizedColumnNames.address && row[parameterizedColumnNames.address],
                // sometimes street number is separated from address
                streetNumber:
                  parameterizedColumnNames.street_number &&
                  row[parameterizedColumnNames.street_number],
                // sometimes street type is separated from address
                streetType:
                  parameterizedColumnNames.street_type && row[parameterizedColumnNames.street_type],
                // fullAddress is address with postal code and city
                fullAddress:
                  parameterizedColumnNames.full_address &&
                  row[parameterizedColumnNames.full_address],
                email: parameterizedColumnNames.email && row[parameterizedColumnNames.email],
                birthDate:
                  parameterizedColumnNames.birth_date &&
                  row[parameterizedColumnNames.birth_date] &&
                  excelDateToString(row[parameterizedColumnNames.birth_date]),
                city: parameterizedColumnNames.city && row[parameterizedColumnNames.city],
                postalCode:
                  parameterizedColumnNames.postal_code && row[parameterizedColumnNames.postal_code],
                phoneNumber:
                  parameterizedColumnNames.phone_number &&
                  row[parameterizedColumnNames.phone_number],
                birthName:
                  parameterizedColumnNames.birth_name && row[parameterizedColumnNames.birth_name],
                departmentInternalId:
                  parameterizedColumnNames.department_internal_id &&
                  row[parameterizedColumnNames.department_internal_id],
                rightsOpeningDate:
                  parameterizedColumnNames.rights_opening_date &&
                  row[parameterizedColumnNames.rights_opening_date] &&
                  excelDateToString(row[parameterizedColumnNames.rights_opening_date]),
              },
              department,
              organisation,
              configuration
            );
            applicantsFromList.push(applicant);
          });
        }
        resolve();
      };
      reader.readAsBinaryString(file);
    });

    return applicantsFromList.reverse();
  };

  const isFormatValid = (file, acceptedFormats) => {
    if (acceptedFormats.some((format) => file.name.endsWith(format))) {
      return { valid: true };
    }
    return { valid: false };
  };

  const displayFormatErrorMessage = (acceptedFormats) => {
    Swal.fire({
      title: `Le fichier doit être au format ${acceptedFormats.map((format) => ` ${format}`)}`,
      icon: "error",
    });
  };

  const handleApplicantsFile = async (file) => {
    const acceptedFormats = [".csv", ".xls", ".xlsx", ".ods"];
    if (!isFormatValid(file, acceptedFormats).valid) {
      displayFormatErrorMessage(acceptedFormats);
      return;
    }

    setFileSize(file.size);
    dispatchApplicants({ type: "reset" });
    const applicantsFromList = await retrieveApplicantsFromList(file);
    if (applicantsFromList.length === 0) return;

    const upToDateApplicants = await retrieveUpToDateApplicants(applicantsFromList);

    upToDateApplicants.forEach((applicant) =>
      dispatchApplicants({
        type: "append",
        item: {
          applicant,
          seed: applicant.uid || applicant.departmentInternalId,
        },
      })
    );
  };

  const handleContactsFile = async (file) => {
    const acceptedFormats = [".csv", ".txt"];
    if (!isFormatValid(file, acceptedFormats).valid) {
      displayFormatErrorMessage(acceptedFormats);
      return;
    }

    setContactsUpdated(false);
    setFileSize(file.size);
    const contactsData = await retrieveContactsData(file);
    if (contactsData.length === 0) return;

    await Promise.all(
      applicants.map(async (item) => {
        let { applicant } = item;
        const applicantContactsData = contactsData.find(
          (a) =>
            // padStart is used because sometimes affiliation numbers are fetched with less than 7 letters
            a.MATRICULE.toString()?.padStart(7, "0") ===
            applicant.affiliationNumber?.padStart(7, "0")
        );
        // if the applicant exists in DB, we don't update the record
        if (applicantContactsData && !applicant.createdAt) {
          applicant = await updateApplicantContactsData(applicant, applicantContactsData);
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
          <h6>({contextName})</h6>
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
