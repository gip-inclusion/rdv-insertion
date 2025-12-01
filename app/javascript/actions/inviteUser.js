import fetchApp from "../lib/fetchApp";

const inviteUser = async (
  userId,
  departmentId,
  organisationId,
  isDepartmentLevel,
  invitationFormat,
  motifCategoryId,
  accept = "application/json"
) => {
  let url;
  if (isDepartmentLevel) {
    url = `/departments/${departmentId}/users/${userId}/invitations`;
  } else {
    url = `/organisations/${organisationId}/users/${userId}/invitations`;
  }
  return fetchApp(
    url,
    {
      method: "POST",
      body: {
        invitation: {
          format: invitationFormat,
          motif_category: { id: motifCategoryId },
        },
      },
      accept,
      parseJson: accept === "application/json",
    }
  );
};

export default inviteUser;
