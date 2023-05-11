import appFetch from "../../lib/appFetch";

const deleteArchiving = async (archivingId) => appFetch(`/archivings/${archivingId}`, "DELETE");

export default deleteArchiving;
