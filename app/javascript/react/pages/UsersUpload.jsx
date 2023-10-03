import React, { useState } from "react";
import Swal from "sweetalert2";
import Tippy from "@tippyjs/react";
import { observer } from "mobx-react-lite";

import * as XLSX from "xlsx";
import FileHandler from "../components/FileHandler";
import EnrichWithContactFile from "../components/EnrichWithContactFile";
import UserBatchActions from "../components/UserBatchActions";
import UserRow from "../components/User";

import getHeaderNames from "../lib/getHeaderNames";
import checkColumnNames from "../lib/checkColumnNames";
import displayMissingColumnsWarning from "../lib/displayMissingColumnsWarning";
import retrieveUpToDateUsers from "../lib/retrieveUpToDateUsers";
import parseContactsData from "../lib/parseContactsData";
import updateUserContactsData from "../lib/updateUserContactsData";
import retrieveContactsData from "../lib/retrieveContactsData";
import { formatDateInput } from "../../lib/datesHelper";
import {
  parameterizeObjectKeys,
  parameterizeObjectValues,
  parameterizeArray,
} from "../../lib/parameterize";

import User from "../models/User";
import usersStore from "../models/Users";

const UsersUpload = observer(
  ({
    users,
    organisation,
    configuration,
    columnNames,
    tags,
    sheetName,
    department,
    motifCategoryName,
    currentAgent,
  }) => {
    const parameterizedColumnNames = parameterizeObjectValues({ ...columnNames });

    const isDepartmentLevel = !organisation;
    const [fileSize, setFileSize] = useState(0);
    /* eslint no-unused-vars: ["error", { "varsIgnorePattern": "contactsUpdated" }] */
    // This state allows to re-renders users after contacts update
    const [contactsUpdated, setContactsUpdated] = useState(false);
    const [showEnrichWithContactFile, setShowEnrichWithContactFile] = useState(false);
    const [showReferentColumn, setShowReferentColumn] = useState(
      configuration && configuration.rdv_with_referents
    );
    const showCarnetColumn = !!department.carnet_de_bord_deploiement_id;

    const redirectToUserList = () => {
      if (configuration) {
        window.location.href = isDepartmentLevel
          ? `/departments/${department.id}/users?motif_category_id=${configuration.motif_category_id}`
          : `/organisations/${organisation.id}/users?motif_category_id=${configuration.motif_category_id}`;
      } else {
        window.location.href = isDepartmentLevel
          ? `/departments/${department.id}/users`
          : `/organisations/${organisation.id}/users`;
      }
    };

    const retrieveUsersFromList = async (file) => {
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
            
            users.columnConfig = parameterizedColumnNames;
            users.showCarnetColumn = showCarnetColumn;
            users.showReferentColumn = showReferentColumn.value;
            users.configuration = configuration;
            users.isDepartmentLevel = isDepartmentLevel;

            rows.forEach((row) => {
              const user = new User(
                // creation and editing to work properly
                {
                  lastName: row[parameterizedColumnNames.last_name_column],
                  firstName: row[parameterizedColumnNames.first_name_column],
                  affiliationNumber: row[parameterizedColumnNames.affiliation_number_column],
                  tags:
                    row[parameterizedColumnNames.tags_column]
                      ?.split(",")
                      .map((tag) => tag.trim()) || [],
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
                tags,
                configuration,
                columnNames,
                currentAgent,
                users
              );
              users.addUser(user);
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

    const handleUsersFile = async (file) => {
      const acceptedFormats = [".csv", ".xls", ".xlsx", ".ods"];
      if (!isFormatValid(file, acceptedFormats)) {
        displayFormatErrorMessage(acceptedFormats);
        return;
      }

      setFileSize(file.size);
      users.setUsers([]);
      await retrieveUsersFromList(file);

      if (users.list.length === 0) return;

      users.setUsers(await retrieveUpToDateUsers(users.list, department.id));
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
        users.list.map(async (user) => {
          const userContactsData = contactsData.find(
            (contactRow) =>
              // padStart is used because sometimes affiliation numbers are fetched with less than 7 letters
              contactRow.MATRICULE.toString()?.padStart(7, "0") ===
              user.affiliationNumber?.padStart(7, "0")
          );
          if (userContactsData) {
            const parsedUserContactsData = await parseContactsData(userContactsData);
            user = await updateUserContactsData(user, parsedUserContactsData);
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
                onClick={() => redirectToUserList()}
              >
                Retour au suivi
              </button>
            </div>
            <div className="col-4 text-center d-flex flex-column align-items-center">
              <h3 className="new-users-title">
                Ajout {isDepartmentLevel ? "au niveau du territoire" : "usagers"}
              </h3>
              {configuration && (
                <h6>
                  ({motifCategoryName}
                  {configuration.rdv_with_referents && " avec réferents"})
                </h6>
              )}

              <FileHandler
                handleFile={handleUsersFile}
                loading={(loading) => users.setLoading(loading)}
                fileSize={fileSize}
                name="users-list-upload"
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
          {!showEnrichWithContactFile && users.list.length > 0 && (
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
          {showEnrichWithContactFile && users.list.length > 0 && (
            <EnrichWithContactFile handleContactsFile={handleContactsFile} fileSize={fileSize} />
          )}
          {users.list.length > 0 && (
            <>
              <div className="row my-1" style={{ height: 50 }}>
                <div className="d-flex justify-content-end align-items-center">
                  <UserBatchActions users={users} />
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
        {users.list.length > 0 && !users.loading && (
          <>
            <div className="my-5 px-4" style={{ overflow: "scroll" }}>
              <table className="table table-hover text-center align-middle table-striped table-bordered">
                <thead className="align-middle dark-blue">
                  <tr>
                    {users.columns.map((column) => {
                      if (!column.visible) return null;

                      return (
                        <th {...column.attributes} key={column.name}>
                          {column.name}
                        </th>
                      )
                    })}
                  </tr>
                </thead>
                <tbody>
                  {users.invalidFirsts.map((user) => (
                    <UserRow user={user} key={user.uniqueKey} />
                  ))}
                </tbody>
              </table>
            </div>
          </>
        )}
      </>
    );
  }
);

export default (props) => <UsersUpload users={usersStore} {...props} />;
