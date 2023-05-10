import appFetch from "../../lib/appFetch";

const archiveApplicant = async (attributes) =>
  appFetch("/archivings", "POST", { archiving: attributes });

export default archiveApplicant;
