import appFetch from "../../lib/appFetch";

const inviteApplicant = async (
  applicantId,
  departmentId,
  organisationId,
  isDepartmentLevel,
  invitationFormat,
  helpPhoneNumber,
  types = "application/json"
) => {
  let url;
  if (isDepartmentLevel) {
    url = `/departments/${departmentId}/applicants/${applicantId}/invitations`;
  } else {
    url = `/organisations/${organisationId}/applicants/${applicantId}/invitations`;
  }
  return appFetch(
    url,
    "POST",
    {
      format: invitationFormat,
      help_phone_number: helpPhoneNumber,
      context: "RSA orientation",
    },
    types
  );
};

export default inviteApplicant;
