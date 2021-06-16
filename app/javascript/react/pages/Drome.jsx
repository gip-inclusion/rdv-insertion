import React from "react"

import FileHandler from "../components/FileHandler";
import { useState, useReducer } from "react";
import * as XLSX from "xlsx";

import { parameterizeObjectKeys } from "../lib/parameterizeObjectKeys";
import { initReducer, reducerFactory } from "../lib/reducers";
import { excelDateToString } from "../lib/datesHelper";

import User from "../models/User";

const SHEET_NAME = "ENTRETIENS PHYSIQUES";

const reducer = reducerFactory("Drôme démo expé");

export default function Drome() {
  const [fileSize, setFileSize] = useState(0);
  const [credentials, setCredentials] = useState({});
  const [users, dispatchUsers] = useReducer(reducer, [], initReducer);
  const devMode = process.env.NODE_ENV == "development";

  const handleFile = file => {
    setFileSize(file.size);

    dispatchUsers({ type: "reset" });

    const reader = new FileReader();
    reader.onload = function (event) {
      const workbook = XLSX.read(event.target.result, { type: "binary" });
      let rows = XLSX.utils.sheet_to_row_object_array(workbook.Sheets[SHEET_NAME]);
      rows = rows.map(row => parameterizeObjectKeys(row));

      rows.forEach(row => {
        const user = new User({
          address: row["adresse"],
          lastName: row["nom-bénéficiaire"],
          firstName: row["prénom-bénéficiaire"],
          email: row["adresses-mails"],
          birthDate: excelDateToString(row["date-de-naissance"]),
          city: row["cp-ville"].split(" ").length > 1 ? row["cp-ville"].split(" ")[1] : "",
          postalCode: row["cp-ville"].split(" ")[0],
          affiliationNumber: row["numero-allocataire"],
          phoneNumber: row["numero-téléphones"],
        });

        dispatchUsers({
          type: "append",
          item: user,
        });
      });
    };

    reader.readAsBinaryString(file);
  };

  return (
    <div className="container mt-5 mb-8">
      <div className="row mt-5 mb-3 justify-content-center">
        <div className="col-4">
          <h1>Expérimentation Drôme</h1>
        </div>
      </div>
      <div className="row justify-content-center">
        <div className="col-4 text-center">
          <FileHandler
            handleFile={handleFile}
            fileSize={fileSize}
            multiple={false}
            uploadMessage={"Glissez votre fichier de nouveaux demandeurs"}
            pendingMessage={"Récupération des informations, merci de patienter"}
          />
        </div>
      </div>
      {/*<div className="row my-5">*/}
        {users.length > 0 && (
          <>
            <div className="row my-5 justify-content-center">
              <div className="col col-4 text-center">
                <button className="btn btn-secondary" onClick={() => dispatchUsers({ type: "reset" })}>
                  Vider l'historique
                </button>
              </div>
            </div>
            <div className="row my-5 justify-content-center">
              <div className="col-8 text-center">
                <table className="table table-hover text-center align-middle table-striped table-bordered">
                  <thead className="align-middle">
                    <tr>
                      <th scope="col">Numéro d'allocataire</th>
                      <th scope="col">Prénom</th>
                      <th scope="col">Nom</th>
                      <th scope="col">Adresse</th>
                      <th scope="col">Email</th>
                      <th scope="col">Téléphone</th>
                      <th scope="col">Date de naissance</th>
                    </tr>
                  </thead>
                  <tbody>
                    {users.map((user, index) => (
                      <tr key={index}>
                        <td>{user.affiliationNumber}</td>
                        <td>{user.firstName}</td>
                        <td>{user.lastName}</td>
                        <td>{user.fullAddress()}</td>
                        <td>{user.email}</td>
                        <td>{user.phoneNumber}</td>
                        <td>{user.birthDate}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </>
        )}
      {/*</div>*/}
    </div>
  );
}
