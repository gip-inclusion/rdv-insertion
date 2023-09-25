/* eslint no-await-in-loop: "off" */
import appFetch from "../../lib/appFetch";

const searchUsers = async (departmentId, nirs, departmentInternalIds, uids, emails, phoneNumbers) =>
  appFetch("/users/searches", "POST", {
    department_id: departmentId,
    users: {
      department_internal_ids: departmentInternalIds,
      uids,
      nirs,
      emails,
      phone_numbers: phoneNumbers,
    },
  });

export default searchUsers;
