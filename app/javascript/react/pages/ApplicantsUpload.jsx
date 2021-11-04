import React, { useState, useReducer } from "react";

import * as XLSX from "xlsx";
import Swal from "sweetalert2";

import FileHandler from "../components/FileHandler";
import ApplicantList from "../components/ApplicantList";

import parameterizeObjectKeys from "../../lib/parameterizeObjectKeys";
import searchApplicants from "../actions/searchApplicants";
import { initReducer, reducerFactory } from "../../lib/reducers";
import { excelDateToString } from "../../lib/datesHelper";

import Applicant from "../models/Applicant";

const reducer = reducerFactory("Expérimentation RSA");

export default function ApplicantsUpload({ organisation, configuration, department }) {
  const SHEET_NAME = configuration.sheet_name;
  const columnNames = configuration.column_names;

  const [fileSize, setFileSize] = useState(0);
  const [applicants, dispatchApplicants] = useReducer(reducer, [], initReducer);

  const retrieveApplicantsFromList = async (file) => {
    const applicantsFromList = [];

    await new Promise((resolve) => {
      const reader = new FileReader();
      reader.onload = function (event) {
        const workbook = XLSX.read(event.target.result, { type: "binary" });
        let rows = XLSX.utils.sheet_to_row_object_array(workbook.Sheets[SHEET_NAME]);
        rows = rows.map((row) => parameterizeObjectKeys(row));
        rows.forEach((row) => {
          const applicant = new Applicant(
            {
              lastName: row[columnNames.last_name],
              firstName: row[columnNames.first_name],
              affiliationNumber: row[columnNames.affiliation_number],
              role: row[columnNames.role],
              title: row[columnNames.title],
              address: columnNames.address && row[columnNames.address],
              fullAddress: columnNames.full_address && row[columnNames.full_address],
              email: columnNames.email && row[columnNames.email],
              birthDate:
                columnNames.birth_date &&
                row[columnNames.birth_date] &&
                excelDateToString(row[columnNames.birth_date]),
              city: columnNames.city && row[columnNames.city],
              postalCode: columnNames.postal_code && row[columnNames.postal_code],
              phoneNumber: columnNames.phone_number && row[columnNames.phone_number],
              birthName: columnNames.birth_name && row[columnNames.birth_name],
              customId: columnNames.custom_id && row[columnNames.custom_id],
            },
            department.number,
            configuration
          );
          applicantsFromList.push(applicant);
        });
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
                    {columnNames.birth_date && <th scope="col">Date de naissance</th>}
                    {columnNames.email && <th scope="col">Email</th>}
                    {columnNames.phone_number && <th scope="col">Téléphone</th>}
                    {columnNames.custom_id && <th scope="col">ID Editeur</th>}
                    <th scope="col">
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
