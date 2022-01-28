import appFetch from "../../lib/appFetch";

const updateApplicant = async (organisationOrDepartmentId, applicantId, attributes = {}, isDepartmentLevel = false) => {
  let url;
  if (isDepartmentLevel) {
    url = `/departments/${organisationOrDepartmentId}/applicants/${applicantId}`;
  } else {
    url = `/organisations/${organisationOrDepartmentId}/applicants/${applicantId}`;
  }
  return appFetch(url, "PATCH", {
    applicant: attributes,
  });
}

export default updateApplicant;
