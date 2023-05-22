import appFetch from "../../lib/appFetch";

const createArchive = async (attributes) => appFetch("/archives", "POST", { archive: attributes });

export default createArchive;
