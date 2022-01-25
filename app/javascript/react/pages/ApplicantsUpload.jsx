import React, { useState, useReducer } from "react";

import * as XLSX from "xlsx";
import Swal from "sweetalert2";

import FileHandler from "../components/FileHandler";
import ApplicantList from "../components/ApplicantList";

import {
  parameterizeObjectKeys,
  parameterizeObjectValues,
  parameterizeArray,
} from "../../lib/parameterize";
import getKeyByValue from "../../lib/getKeyByValue";
import searchApplicants from "../actions/searchApplicants";
import { initReducer, reducerFactory } from "../../lib/reducers";
import { excelDateToString } from "../../lib/datesHelper";

import Applicant from "../models/Applicant";

const reducer = reducerFactory("Expérimentation RSA");

export default function ApplicantsUpload({ organisation, configuration, department }) {
  const SHEET_NAME = configuration.sheet_name;
  const columnNames = configuration.column_names;
  const parameterizedColumnNames = parameterizeObjectValues({
    ...columnNames.required,
    ...columnNames.optional,
  });
  const contactsColumnNames = ["MATRICULE", "ROLE PERSONNE", "TYPE PERSONNE", "NIR",
    "NUMERO DEMANDE RSA", "DATE DEMANDE RSA", "DATE DEBUT DROITS - DEVOIRS",
    "NOM RESPONSABLE DOSSIER", "PRENOM RESPONSABLE DOSSIER", "NUMERO TELEPHONE DOSSIER",
    "NUMERO TELEPHONE 2 DOSSIER","ADRESSE ELECTRONIQUE DOSSIER"]
  const isDepartmentLevel = !organisation;

  const [fileSize, setFileSize] = useState(0);
  const [contactsData, setContactsData] = useState([]);
  const [applicants, dispatchApplicants] = useReducer(reducer, [], initReducer);

  const getHeaderNames = (sheet) => {
    const header = [];
    const columnCount = XLSX.utils.decode_range(sheet["!ref"]).e.c + 1;
    for (let i = 0; i < columnCount; i += 1) {
      if (sheet[`${XLSX.utils.encode_col(i)}1`] !== undefined) {
        header[i] = sheet[`${XLSX.utils.encode_col(i)}1`].v;
      }
    }
    return header;
  }

  const checkColumnNames = (uploadedColumnNames, fileType = "applicants") => {
    let requiredColumns = null;
    const missingColumnNames = [];
    if (fileType === "applicants") {
      requiredColumns = parameterizeObjectValues(columnNames.required);
    } else {
      requiredColumns = contactsColumnNames;
    }
    const expectedColumnNames = Object.values(requiredColumns);
    const missingColumns = expectedColumnNames.filter(
      (colName) => !uploadedColumnNames.includes(colName)
    );
    if (missingColumns.length > 0) {
      // Récupère les noms "humains" des colonnes manquantes
      missingColumns.forEach((col) => {
        const missingAttribute = getKeyByValue(requiredColumns, col);
        let missingColumnName = null;
        if (fileType === "applicants") {
          missingColumnName = configuration.column_names.required[missingAttribute];
        } else {
          missingColumnName = contactsColumnNames[missingAttribute];
        }
        missingColumnNames.push(missingColumnName);
      });
      Swal.fire({
        title: "Le fichier chargé ne correspond pas au format attendu",
        html: `Veuillez vérifier que les colonnes suivantes sont présentes et correctement nommées&nbsp;:
        <br/>
        <strong>${missingColumnNames.join("<br />")}</strong>`,
        icon: "error",
      });
      }
    return missingColumnNames;
  };

  const retrieveApplicantsFromList = async (file) => {
    const applicantsFromList = [];

    await new Promise((resolve) => {
      const reader = new FileReader();
      reader.onload = function (event) {
        const workbook = XLSX.read(event.target.result, { type: "binary" });
        const sheet = workbook.Sheets[SHEET_NAME] || workbook.Sheets[workbook.SheetNames[0]];
        const headerNames = getHeaderNames(sheet);
        const missingColumnNames = checkColumnNames(parameterizeArray(headerNames));
        let rows = XLSX.utils.sheet_to_row_object_array(sheet);
        rows = rows.map((row) => parameterizeObjectKeys(row));
        if (missingColumnNames.length === 0) {
          rows.forEach((row) => {
            const applicant = new Applicant(
              {
                lastName: row[parameterizedColumnNames.last_name],
                firstName: row[parameterizedColumnNames.first_name],
                affiliationNumber: row[parameterizedColumnNames.affiliation_number],
                role: row[parameterizedColumnNames.role],
                title: row[parameterizedColumnNames.title],
                address: parameterizedColumnNames.address && row[parameterizedColumnNames.address],
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

  const retrieveApplicantsFromApp = async (uids) => {
    const result = await searchApplicants(uids);
    if (result.success) {
      return result.applicants;
    }
    Swal.fire(
      "Une erreur s'est produite en récupérant les infos utilisateurs sur le serveur",
      result.errors && result.errors.join(" - "),
      "warning"
    );
    return null;
  };

  const retrieveUpToDateApplicants = async (applicantsFromList) => {
    const uids = applicantsFromList.map((applicant) => applicant.uid).filter((uid) => uid);
    let upToDateApplicants = applicantsFromList;

    const retrievedApplicants = await retrieveApplicantsFromApp(uids);

    upToDateApplicants = applicantsFromList.map((applicant) => {
      const upToDateApplicant = retrievedApplicants.find((a) => a.uid === applicant.uid);
      if (upToDateApplicant) {
        applicant.updateWith(upToDateApplicant);
      }
      return applicant;
    });

    return upToDateApplicants;
  };

  const redirectToApplicantList = () => {
    window.location.href = isDepartmentLevel
      ? `/departments/${department.id}/applicants`
      : `/organisations/${organisation.id}/applicants`;
  };

  const handleApplicantsFile = async (file) => {
    setFileSize(file.size);

    dispatchApplicants({ type: "reset" });
    const applicantsFromList = await retrieveApplicantsFromList(file);
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

  const retrieveContactsData = async (file) => {
    let contacts = [];

    await new Promise((resolve) => {
      const reader = new FileReader();
      reader.onload = function (event) {
        const sheet = XLSX.read(event.target.result, {type: "string"}).Sheets.Sheet1;
        const headerNames = getHeaderNames(sheet);
        const missingColumnNames = checkColumnNames(headerNames, "contacts");
        if (missingColumnNames.length === 0) {
          contacts = XLSX.utils.sheet_to_json(sheet, { raw: false });
        }
        resolve();
      };
      reader.readAsBinaryString(file);
    });
    return contacts;
  };

  const handleContactsFile = async (file) => {
    setFileSize(file.size);

    const result = await retrieveContactsData(file);
    if (result.length === 0) return;

    setContactsData(result);
  };

  return (
    <div className="container mt-5 mb-8">
      <div className="row mb-4 block-white justify-content-center">
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
            multiple={false}
            uploadMessage="Choisissez un fichier de nouveaux demandeurs"
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
      {applicants.length > 0 && (
        <>
          <div className="row mb-4 block-white justify-content-center">
            <div className="col-4" />
            <div className="col-4 text-center d-flex flex-column align-items-center">
              <h3 className="new-applicants-title">
                Enrichir données de contacts
              </h3>
              <FileHandler
                handleFile={handleContactsFile}
                fileSize={fileSize}
                multiple={false}
                uploadMessage="Choisissez un fichier de données de contact"
                pendingMessage="Récupération des informations, merci de patienter"
              />
            </div>
            <div className="col-4" />
          </div>

        </>
      )}

      {applicants.length > 0 && (
        <>
          <div className="row my-5 justify-content-center">
            <div className="text-center">
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
                    {(configuration.invitation_format === "sms" ||
                      configuration.invitation_format === "sms_and_email") && (
                      <>
                        <th scope="col-3">Invitation SMS</th>
                      </>
                    )}
                    {(configuration.invitation_format === "email" ||
                      configuration.invitation_format === "sms_and_email") && (
                      <>
                        <th scope="col-3">Invitation mail</th>
                      </>
                    )}
                  </tr>
                </thead>
                <tbody>
                  <ApplicantList
                    applicants={applicants}
                    dispatchApplicants={dispatchApplicants}
                    contactsData={contactsData}
                    isDepartmentLevel={isDepartmentLevel}
                  />
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
