import Swal from "sweetalert2";
import searchApplicants from "../actions/searchApplicants";
import findDuplicates from "../../lib/findDuplicates";
import processApplicantsDuplicates from "./processApplicantsDuplicates";

const retrieveApplicantsFromApp = async (departmentInternalIds, uids) => {
  const result = await searchApplicants(departmentInternalIds, uids);
  if (result.success) {
    return result.applicants;
  }
  Swal.fire(
    "Une erreur s'est produite en récupérant les infos utilisateurs sur le serveur",
    result.errors && result.errors.join(" - "),
    "warning"
  );
  return null;
};

const retrieveUpToDateApplicants = async (applicantsFromList) => {
  const departmentInternalIds = applicantsFromList
    .map((applicant) => applicant.departmentInternalId)
    .filter((departmentInternalId) => departmentInternalId);
  const uids = applicantsFromList.map((applicant) => applicant.uid).filter((uid) => uid);

  const duplicatesDepartmentInternalIds = findDuplicates(departmentInternalIds);
  const duplicatesUids = findDuplicates(uids);

  const retrievedApplicants = await retrieveApplicantsFromApp(departmentInternalIds, uids);

  const upToDateApplicants = applicantsFromList.map((applicant) => {
    const upToDateApplicant = retrievedApplicants.find(
      (a) =>
        (a.department_internal_id && a.department_internal_id === applicant.departmentInternalId) ||
        (a.uid && a.uid === applicant.uid)
    );

    if (upToDateApplicant) {
      applicant.updateWith(upToDateApplicant);
    } else if (
      (applicant.departmentInternalId &&
        duplicatesDepartmentInternalIds.includes(applicant.departmentInternalId)) ||
      (applicant.uid && duplicatesUids.includes(applicant.uid))
    ) {
      processApplicantsDuplicates(applicantsFromList, applicant);
    }
    return applicant;
  });

  return upToDateApplicants;
};

export default retrieveUpToDateApplicants;
