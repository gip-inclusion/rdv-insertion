import appFetch from "../../lib/appFetch";

const deleteArchive = async (archiveId) => appFetch(`/archives/${archiveId}`, "DELETE");

export default deleteArchive;
