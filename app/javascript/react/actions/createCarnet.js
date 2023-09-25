import appFetch from "../../lib/appFetch";

const createCarnet = async (userId, departmentId) =>
  appFetch("/carnet_de_bord/carnets", "POST", {
    carnet: {
      user_id: userId,
      department_id: departmentId,
    },
  });

export default createCarnet;
