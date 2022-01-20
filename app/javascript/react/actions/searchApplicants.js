/* eslint no-await-in-loop: "off" */

import appFetch from "../../lib/appFetch";

const searchApplicants = async (uids) =>
  appFetch("/applicants/search", "POST", {
    applicants: { uids },
  });

export default searchApplicants;
