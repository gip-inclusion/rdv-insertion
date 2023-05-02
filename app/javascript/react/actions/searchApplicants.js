/* eslint no-await-in-loop: "off" */
import appFetch from "../../lib/appFetch";

const searchApplicants = async (
  departmentId,
  nirs,
  departmentInternalIds,
  uids,
  emails,
  phoneNumbers
) =>
  appFetch("/applicants/searches", "POST", {
    department_id: departmentId,
    applicants: {
      department_internal_ids: departmentInternalIds,
      uids,
      nirs,
      emails,
      phone_numbers: phoneNumbers,
    },
  });

export default searchApplicants;
