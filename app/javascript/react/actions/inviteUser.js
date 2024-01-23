import appFetch from "../../lib/appFetch";

const inviteUser = async (
  userId,
  departmentId,
  organisationId,
  isDepartmentLevel,
  invitationFormat,
  motifCategoryId,
  types = "application/json"
) => {
  let url;
  if (isDepartmentLevel) {
    url = `/departments/${departmentId}/users/${userId}/invitations`;
  } else {
    url = `/organisations/${organisationId}/users/${userId}/invitations`;
  }
  return appFetch(
    url,
    "POST",
    {
      invitation: {
        format: invitationFormat,
        motif_category: { id: motifCategoryId },
      },
    },
    types
  );
};

export default inviteUser;
