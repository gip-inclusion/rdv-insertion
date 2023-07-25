import appFetch from "../../lib/appFetch";

const createCarnet = async (applicantId, departmentId) =>
  appFetch("/carnet_de_bord/carnets", "POST", {
    carnet: {
      applicant_id: applicantId,
      department_id: departmentId,
    },
  });

export default createCarnet;
