import appFetch from "../../lib/appFetch";

const unarchiveApplicant = async (archivingId) => appFetch(`/archivings/${archivingId}`, "DELETE");

export default unarchiveApplicant;
