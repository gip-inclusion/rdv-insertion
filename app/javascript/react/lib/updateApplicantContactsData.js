const updateApplicantContactsData = (applicant, parsedApplicantContactsData) => {
  ["email", "phoneNumber", "rightsOpeningDate"].forEach((attributeName) => {
    const attribute = parsedApplicantContactsData[attributeName];
    if (attribute && applicant[attributeName] !== attribute) {
      applicant[`${attributeName}New`] = attribute;
    }
  });
  return applicant;
};

export default updateApplicantContactsData;
