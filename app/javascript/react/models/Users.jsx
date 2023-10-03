import React from "react";
import { makeAutoObservable } from "mobx";

import CreationCell from "../components/user/CreationCell";
import ReferentAssignationCell from "../components/user/ReferentAssignationCell";
import CarnetCreationCell from "../components/user/CarnetCreationCell";
import EditableCell from "../components/user/EditableCell";

class Users {
  constructor() {
    this.list = [];
    this.loading = false;
    this.columnConfig = [];
    this.showCarnetColumn = false
    this.configuration = null
    this.showReferentColumn = false
    this.isDepartmentLevel = false
    makeAutoObservable(this);
  }

  get columns() {
    return [
      {
        name: "Séléction",
        key: "selection",
        attributes: {
          className: "text-center",
          scope: "col"
        },
        content: ({ user }) => (
            <td>
              <input
              type="checkbox"
              className="form-check-input"
              checked={user.selected}
              onChange={(event) => {
                user.selected = event.target.checked;
              }}
            />
            </td>
        )
      },
      {
        name: "Civilité",
        key: "civility",
        content: ({ user }) => (
          <td>
            <EditableCell
              type="select"
              user={user}
              cell="title"
              values={[
                { key: "M", value: "monsieur" },
                { key: "Mme", value: "madame" },
              ]}
            />
          </td>
        )
      },
      {
        name: "Prénom",
        key: "firstName",
        content: ({ user }) => (
          <td>
            <EditableCell type="text" user={user} cell="firstName" />
          </td>
        )
      },
      {
        name: "Nom",
        key: "lastName",
        content: ({ user }) => (
          <td>
            <EditableCell type="text" user={user} cell="lastName" />
          </td>
        )
      },
      {
        name: "Numéro CAF", 
        key: "affiliationNumber",
        visible: this.columnConfig.affiliation_number_column,
        content: ({ user }) => (
          <td>
            <EditableCell type="text" user={user} cell="affiliationNumber" />
          </td>
        )
      },
      {
        name: "Rôle",
        key: "role",
        visible: this.columnConfig.role_column,
        content: ({ user }) => (
          <td>
            <EditableCell
            user={user}
            cell="role"
            type="select"
            values={[
              { key: "DEM", value: "demandeur" },
              { key: "CJT", value: "conjoint" },
            ]}
          />
          </td>
        )
      },
      {
        name: "ID Editeur",
        key: "departmentInternalId",
        visible: this.columnConfig.department_internal_id_column,
        content: ({ user }) => (
          <td>
            <EditableCell user={user} cell="departmentInternalId" />
          </td>
        )
      },
      {
        name: "NIR",
        key: "nir",
        visible: this.columnConfig.nir_column,
        content: ({ user }) => (
          <td>{user.nir ?? " - "}</td>
        )
      },
      {
        name: "ID PE",
        key: "pole_emploi_id",
        visible: this.columnConfig.pole_emploi_id_column,
        content: ({ user }) => (
          <td>{user.poleEmploiId ?? " - "}</td>
        )
      },
      {
        name: "Email",
        key: "email",
        isInContactFile: true,
        visible: this.columnConfig.email_column,
        content: ({ user }) => (
          <td className={user.emailUpdated ? "table-success" : ""}>
            <EditableCell user={user} cell="email" />
          </td>
        )
      },
      {
        name: "Téléphone",
        key: "phoneNumber",
        isInContactFile: true,
        visible: this.columnConfig.phone_number_column,
        content: ({ user }) => (
          <td className={user.phoneNumberUpdated ? "table-success" : ""}>
            <EditableCell user={user} cell="phoneNumber" />
          </td>
        )
      },
      {
        name: "Tags",
        key: "tags",
        visible: this.columnConfig.tags_column,
        content: ({ user }) => (
          <td className={user.tagsUpdated ? "table-success" : ""}>
            <EditableCell
              user={user}
              cell="tags"
              type="tags"
              values={user.availableTags.map((tag) => tag.value)}
            />
          </td>
        )
      },
      {
        name:  "Date d&apos;entrée flux",
        key: "rightsOpeningDate",
        isInContactFile: true,
        visible: this.columnConfig.rights_opening_date_column,
        content: ({ user }) => (
          <td className={user.rightsOpeningDateUpdated ? "table-success" : ""}>
            <EditableCell user={user} cell="rightsOpeningDate" />
          </td>
        )
      },
      {
        name: "Création compte",
        key: "create_account",
        attributes: {
          style: {
            whiteSpace: "nowrap"
          },
          scope: "col"
        },
        content: ({ user }) => (
          <CreationCell user={user} />
        )
      },
      {
        name: "Création carnet",
        key: "create_carnet",
        attributes: {
          style: {
            whiteSpace: "nowrap"
          },
          scope: "col"
        },
        visible: this.showCarnetColumn,
        content: ({ user }) => (
          <CarnetCreationCell user={user} />
        )
      },
      {
        name: "Référent",
        key: "referent",
        attributes: { scope: "col-3" },
        visible: this.showReferentColumn,
        content: ({ user }) => (
          <ReferentAssignationCell user={user} />
        )
      },
      {
        name: "Invitation SMS",
        key: "invitation_sms",
        visible: this.configuration?.invitation_formats?.includes("sms"),
        attributes: { scope: "col-3" }
      },
      {
        name: "Invitation mail",
        key: "invitation_email",
        visible: this.configuration?.invitation_formats?.includes("email"),
        attributes: { scope: "col-3" }
      },
      {
        name: "Invitation courrier",
        key: "invitation_postal",
        visible: this.configuration?.invitation_formats?.includes("postal"),
        attributes: { scope: "col-3" }
      }
    ].map(column => ({
      attributes: { scope: "col" },
      visible: true,
      isInContactFile: false,
      ...column
    }))
  }

  get numberOfColumnsBeforeContactListUpdate() {
    let offset = 0;
    // eslint-disable-next-line no-restricted-syntax
    for (const column of this.columns) {
      if (column.isInContactFile) break
      if (column.visible) offset += 1;
    }
    return offset
  }

  addUser(user) {
    this.list.push(user);
  }

  setUsers(users) {
    this.list = users;
  }

  setLoading(loading) {
    this.loading = loading;
  }

  get selectedUsers() {
    return this.list.filter((user) => user.selected);
  }

  get invalidFirsts() {
    return this.list.slice().sort((a, b) => {
      if (a.isValid !== b.isValid) {
        return a.isValid ? 1 : -1;
      }
      return null;
    });
  }
}

export default new Users();
