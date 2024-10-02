import Swal from "sweetalert2";
import searchUsers from "../actions/searchUsers";

const retrieveUsersFromApp = async (
  departmentId,
  nirs,
  departmentInternalIds,
  uids,
  emails,
  phoneNumbers
) => {
  const result = await searchUsers(
    departmentId,
    nirs,
    departmentInternalIds,
    uids,
    emails,
    phoneNumbers
  );
  if (result.success) {
    return result.users;
  }
  Swal.fire(
    "Une erreur s'est produite en récupérant les infos des usagers sur le serveur",
    result.errors && result.errors.join(" - "),
    "warning"
  );
  return null;
};

const retrieveAttributes = (users, attributeName) =>
  users.map((user) => user[attributeName]).filter((attribute) => attribute);

const retrieveUpToDateUsers = async (usersFromList, departmentId) => {
  const nirs = retrieveAttributes(usersFromList, "nir");
  const departmentInternalIds = retrieveAttributes(usersFromList, "departmentInternalId");
  const uids = retrieveAttributes(usersFromList, "uid");
  const emails = retrieveAttributes(usersFromList, "email");
  const phoneNumbers = retrieveAttributes(usersFromList, "phoneNumber");

  const retrievedUsers = await retrieveUsersFromApp(
    departmentId,
    nirs,
    departmentInternalIds,
    uids,
    emails,
    phoneNumbers
  );

  const upToDateUsers = usersFromList.map((user) => {
    const upToDateUser = retrievedUsers.find(
      (a) =>
        (a.nir && a.nir.substring(0, 13) === user.nir?.substring(0, 13)) ||
        (a.department_internal_id && a.department_internal_id === user.departmentInternalId) ||
        (a.uid && a.uid === user.uid) ||
        (a.email &&
          a.email === user.email &&
          a.first_name.split(" ")[0].toLowerCase() ===
          user.firstName.split(" ")[0].toLowerCase()) ||
        (a.phone_number &&
          // since the phone are not formatted in the file we compare the 8 last digits
          a.phone_number.slice(-8) === user.phoneNumber?.slice(-8) &&
          a.first_name.split(" ")[0].toLowerCase() === user.firstName.split(" ")[0].toLowerCase())
    );

    if (upToDateUser) {
      user.updateWith(upToDateUser);
    }

    return user;
  });

  return upToDateUsers;
};

export default retrieveUpToDateUsers;
