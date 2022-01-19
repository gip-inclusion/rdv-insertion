import appFetch from "../../lib/appFetch";

const inviteApplicant = async (
  applicantId,
  departmentId,
  organisationId,
  isDepartmentLevel,
  invitationFormat,
  rescuePhoneNumber
) => {
  let url;
  if (isDepartmentLevel) {
    url = `/departments/${departmentId}/applicants/${applicantId}/invitations`;
  } else {
    url = `/organisations/${organisationId}/applicants/${applicantId}/invitations`;
  }
  return appFetch(url, "POST", {
    format: invitationFormat,
    rescue_phone_number: rescuePhoneNumber,
    context: "RSA orientation",
  });
};

export default inviteApplicant;
