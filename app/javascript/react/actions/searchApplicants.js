/* eslint no-await-in-loop: "off" */
import appFetch from "../../lib/appFetch";

const searchApplicants = async (departmentInternalIds, uids) =>
  appFetch("/applicants/search", "POST", {
    applicants: { department_internal_ids: departmentInternalIds, uids },
  });

export default searchApplicants;
