import fetchApp from "../../lib/fetchApp";

const deleteArchive = async (archiveId, organisationId) => fetchApp(`/organisations/${organisationId}/archives/${archiveId}`, {
  method: "DELETE",
  parseJson: true,
});

export default deleteArchive;
