/* eslint no-await-in-loop: "off" */
import fetchApp from "../../lib/fetchApp";

const searchUsers = async (departmentId, nirs, departmentInternalIds, uids, emails, phoneNumbers) =>
  fetchApp("/users/searches", {
    method: "POST",
    body: {
      department_id: departmentId,
      users: {
        department_internal_ids: departmentInternalIds,
        uids,
        nirs,
        emails,
        phone_numbers: phoneNumbers,
      },
    },
    parseJson: true,
  });

export default searchUsers;
