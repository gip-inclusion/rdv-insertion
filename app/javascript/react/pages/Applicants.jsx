import React, { useState, useReducer } from "react";

import * as XLSX from "xlsx";

import FileHandler from "../components/FileHandler";
import ApplicantList from "../components/ApplicantList";

import parameterizeObjectKeys from "../lib/parameterizeObjectKeys";
import searchApplicants from "../actions/searchApplicants";
import { initReducer, reducerFactory } from "../lib/reducers";
import { excelDateToString } from "../lib/datesHelper";

import Applicant from "../models/Applicant";

const reducer = reducerFactory("Expérimentation RSA");

export default function Applicants({ department, configuration }) {
  const SHEET_NAME = configuration.sheet_name;

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
              address: row.adresse,
              lastName: row["nom-beneficiaire"],
              firstName: row["prenom-beneficiaire"],
              email: row["adresses-mails"],
              birthDate: excelDateToString(row["date-de-naissance"]),
              city: row["cp-ville"].split(" ").length > 1 ? row["cp-ville"].split(" ")[1] : "",
              postalCode: row["cp-ville"].split(" ")[0],
              affiliationNumber: row["numero-allocataire"],
              role: row.role,
              phoneNumber: row["numero-telephones"],
            },
            department.number
          );
          applicantsFromList.push(applicant);
        });
        resolve();
      };
      reader.readAsBinaryString(file);
    });

    return applicantsFromList;
  };

  const addStatusesToApplicants = async (applicantsFromList) => {
    const uids = applicantsFromList.map((applicant) => applicant.uid);
    let augmentedApplicants = applicantsFromList;

    const retrievedApplicants = await searchApplicants(uids);

    augmentedApplicants = applicantsFromList.map((applicant) => {
      const augmentedApplicant = retrievedApplicants.find((a) => a.uid === applicant.uid);
      if (augmentedApplicant) {
        applicant.augmentWith(augmentedApplicant);
      }
      return applicant;
    });

    return augmentedApplicants;
  };

  const handleFile = async (file) => {
    setFileSize(file.size);

    dispatchApplicants({ type: "reset" });
    const applicantsFromList = await retrieveApplicantsFromList(file);

    const augmentedApplicants = await addStatusesToApplicants(applicantsFromList);

    augmentedApplicants.forEach((applicant) => {
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
      <div className="row mt-5 mb-3 justify-content-center">
        <div className="col-4">
          <h1>Expérimentation {department.name}</h1>
        </div>
      </div>
      <div className="row justify-content-center">
        <div className="col-4 text-center">
          <FileHandler
            handleFile={handleFile}
            fileSize={fileSize}
            multiple={false}
            uploadMessage="Glissez votre fichier de nouveaux demandeurs"
            pendingMessage="Récupération des informations, merci de patienter"
          />
        </div>
      </div>
      {applicants.length > 0 && (
        <>
          <div className="row my-5 justify-content-center">
            <div className="col col-4 text-center">
              <button
                type="submit"
                className="btn btn-secondary"
                onClick={() => dispatchApplicants({ type: "reset" })}
              >
                Vider l&apos;historique
              </button>
            </div>
          </div>
          <div className="row my-5 justify-content-center">
            <div className="text-center">
              <table className="table table-hover text-center align-middle table-striped table-bordered">
                <thead className="align-middle">
                  <tr>
                    <th scope="col">Numéro d&apos;allocataire</th>
                    <th scope="col">Prénom</th>
                    <th scope="col">Nom</th>
                    <th scope="col">Adresse</th>
                    <th scope="col">Email</th>
                    <th scope="col">Téléphone</th>
                    <th scope="col">Date de naissance</th>
                    <th scope="col">Rôle</th>
                    <th scope="col" style={{ whiteSpace: "nowrap" }}>
                      Créé le
                    </th>
                    <th scope="col" style={{ whiteSpace: "nowrap" }}>
                      Invité le
                    </th>
                    <th scope="col">Action</th>
                  </tr>
                </thead>
                <tbody>
                  <ApplicantList
                    applicants={applicants}
                    dispatchApplicants={dispatchApplicants}
                    department={department}
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
