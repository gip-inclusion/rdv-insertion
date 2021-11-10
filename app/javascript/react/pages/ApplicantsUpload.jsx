import React, { useState, useReducer } from "react";

import * as XLSX from "xlsx";
import Swal from "sweetalert2";

import FileHandler from "../components/FileHandler";
import ApplicantList from "../components/ApplicantList";

import { parameterizeObjectKeys, parameterizeObjectValues, parameterizeArray } from "../../lib/parameterize";
import getKeyByValue from "../../lib/getKeyByValue";
import searchApplicants from "../actions/searchApplicants";
import { initReducer, reducerFactory } from "../../lib/reducers";
import { excelDateToString } from "../../lib/datesHelper";

import Applicant from "../models/Applicant";

const reducer = reducerFactory("Expérimentation RSA");

export default function ApplicantsUpload({ organisation, configuration, department }) {
  const SHEET_NAME = configuration.sheet_name;
  const columnNames = configuration.column_names;
  const parameterizedColumnNames = parameterizeObjectValues({ ...columnNames.required, ...columnNames.optional });

  const [fileSize, setFileSize] = useState(0);
  const [applicants, dispatchApplicants] = useReducer(reducer, [], initReducer);

  const checkColumnNames = (uploadedColumnNames) => {
    const missingColumnNames = [];
    const requiredColumns = parameterizeObjectValues(columnNames.required);

    const expectedColumnNames = Object.values(requiredColumns);
    const parameterizedMissingColumns =
      expectedColumnNames.filter(colName => !uploadedColumnNames.includes(colName));

    if (parameterizedMissingColumns.length > 0) {
      // Récupère les noms "humains" des colonnes manquantes
      parameterizedMissingColumns.forEach((col) => {
        const missingAttribute = getKeyByValue(requiredColumns, col);
        const missingColumnName = configuration.column_names.required[missingAttribute];
        missingColumnNames.push(missingColumnName);
      });

      Swal.fire({
        title: "Le fichier chargé ne correspond pas au format attendu",
        html: `Veuillez vérifier que les colonnes suivantes sont présentes et correctement nommées&nbsp;:
        <br/>
        <strong>${missingColumnNames.join("<br />")}</strong>`,
        icon: "error"
      });
    }
    return missingColumnNames;
  }

  const retrieveApplicantsFromList = async (file) => {
    const applicantsFromList = [];

    await new Promise((resolve) => {
      const reader = new FileReader();
      reader.onload = function (event) {
        const workbook = XLSX.read(event.target.result, { type: "binary" });
        const sheet = workbook.Sheets[SHEET_NAME] || workbook.Sheets[workbook.SheetNames[0]];
        const header = []
        const columnCount = XLSX.utils.decode_range(sheet["!ref"]).e.c + 1
        for (let i = 0; i < columnCount; i += 1) {
          header[i] = sheet[`${XLSX.utils.encode_col(i)}1`].v
        }
        const missingColumnNames = checkColumnNames(parameterizeArray(header));
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
                fullAddress: parameterizedColumnNames.full_address
                  && row[parameterizedColumnNames.full_address],
                email: parameterizedColumnNames.email && row[parameterizedColumnNames.email],
                birthDate:
                  parameterizedColumnNames.birth_date &&
                  row[parameterizedColumnNames.birth_date] &&
                  excelDateToString(row[parameterizedColumnNames.birth_date]),
                city: parameterizedColumnNames.city && row[parameterizedColumnNames.city],
                postalCode: parameterizedColumnNames.postal_code
                  && row[parameterizedColumnNames.postal_code],
                phoneNumber: parameterizedColumnNames.phone_number
                  && row[parameterizedColumnNames.phone_number],
                birthName: parameterizedColumnNames.birth_name
                  && row[parameterizedColumnNames.birth_name],
                customId: parameterizedColumnNames.custom_id
                  && row[parameterizedColumnNames.custom_id],
              },
              department.number,
              configuration
            );
            applicantsFromList.push(applicant);
          });
        };
        resolve();
      };
      reader.readAsBinaryString(file);
    });

    return applicantsFromList.reverse();
  };

  const retrieveApplicantsFromApp = async (uids) => {
    const result = await searchApplicants(organisation.id, uids);
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
    window.location.href = `/organisations/${organisation.id}/applicants`;
  };

  const handleFile = async (file) => {
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
          <h3 className="new-applicants-title">Ajout allocataires</h3>
          <FileHandler
            handleFile={handleFile}
            fileSize={fileSize}
            multiple={false}
            uploadMessage="Choisissez un fichier de nouveaux demandeurs"
            pendingMessage="Récupération des informations, merci de patienter"
          />
        </div>
        <div className="col-4 text-center" />
      </div>

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
                    {parameterizedColumnNames.custom_id && <th scope="col">ID Editeur</th>}
                    <th scope="col" style={{ whiteSpace: "nowrap" }}>
                      Création compte
                    </th>
                    {(configuration.invitation_format === "sms" ||
                      configuration.invitation_format === "sms_and_email") && (
                      <>
                        <th scope="col-3">
                          Invitation SMS
                        </th>
                      </>
                    )}
                    {(configuration.invitation_format === "email" ||
                      configuration.invitation_format === "sms_and_email") && (
                      <>
                        <th scope="col-3">
                          Invitation mail
                        </th>
                      </>
                    )}
                  </tr>
                </thead>
                <tbody>
                  <ApplicantList
                    applicants={applicants}
                    dispatchApplicants={dispatchApplicants}
                    organisation={organisation}
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
