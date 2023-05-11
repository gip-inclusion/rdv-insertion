import appFetch from "../../lib/appFetch";

const createArchiving = async (attributes) =>
  appFetch("/archivings", "POST", { archiving: attributes });

export default createArchiving;
