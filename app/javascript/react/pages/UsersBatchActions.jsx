import React, { useEffect } from "react";
import { observer } from "mobx-react-lite";

import UsersActionsList from "../components/UsersActionsList";

import { formatDateInput } from "../../lib/datesHelper";

import User from "../models/User";
import usersStore from "../models/Users";

const UsersBatchActions = observer(
  ({
    users,
    usersFromApp,
    organisation,
    configuration,
    department,
    currentAgent,
  }) => {

    const isDepartmentLevel = !organisation;

    useEffect(() => {
      users.setUsers([]);
      users.showReferentColumn = configuration?.rdv_with_referents;
      users.configuration = configuration;
      users.isDepartmentLevel = isDepartmentLevel;

      usersFromApp.forEach((userFromApp) => {
        const user = new User(
          {
            lastName: userFromApp.last_name,
            firstName: userFromApp.first_name,
            affiliationNumber: userFromApp.affiliation_number,
            tags: userFromApp.tags,
            nir: userFromApp.nir,
            poleEmploiId: userFromApp.pole_emploi_id,
            role: userFromApp.role,
            title: userFromApp.title,
            fullAddress: userFromApp.address,
            email: userFromApp.email,
            phoneNumber: userFromApp.phone_number,
            birthDate: formatDateInput(userFromApp.birth_date),
            birthName: userFromApp.birth_name,
            departmentInternalId: userFromApp.department_internal_id,
            rightsOpeningDate: formatDateInput(userFromApp.rights_opening_date),
            referentEmail: userFromApp.referent_email,
          },
          department,
          organisation,
          configuration,
          currentAgent,
          users
        );
        user.updateWith(userFromApp);

        users.addUser(user);
      }
    );
  }, [usersFromApp]);

    // const redirectToUserList = () => {
    //   const scope = isDepartmentLevel ? "departments" : "organisations";
    //   const url = `/${scope}/${(organisation || department).id}/users`;
    //   const queryParams = configuration
    //     ? `?motif_category_id=${configuration.motif_category_id}`
    //     : "";

    //   window.location.href = url + queryParams;
    // };

    return (
      <>
        {users.list.length > 0 && !users.loading && (
          <UsersActionsList users={users} />
        )}
      </>
    );
  }
);

export default (props) => <UsersBatchActions users={usersStore} {...props} />;
