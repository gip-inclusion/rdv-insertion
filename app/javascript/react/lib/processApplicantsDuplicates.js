const processApplicantsDuplicates = (applicantsFromList, applicant) => {
  const reversedApplicantsList = applicantsFromList.map(
    (element, index, array) => array[array.length - 1 - index]
  );
  const mainApplicant = reversedApplicantsList.find(
    (a) =>
      (applicant.departmentInternalId &&
        a.departmentInternalId === applicant.departmentInternalId) ||
      (applicant.uid && a.uid === applicant.uid)
  );
  if (mainApplicant !== applicant) {
    applicant.isDuplicate = true;
  }
};

export default processApplicantsDuplicates;
