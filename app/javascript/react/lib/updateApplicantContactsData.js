const updateExistingApplicantContactsData = async (applicant, parsedApplicantContactsData) => {
  ["email", "phoneNumber", "rightsOpeningDate"].forEach((attributeName) => {
    const attribute = parsedApplicantContactsData[attributeName];
    if (attribute && applicant[attributeName] !== attribute) {
      applicant[`${attributeName}New`] = attribute;
    }
  });
  return applicant;
};

const updateNewApplicantContactsData = (applicant, parsedApplicantContactsData) => {
  const { phoneNumber } = parsedApplicantContactsData;
  const { email } = parsedApplicantContactsData;
  const { rightsOpeningDate } = parsedApplicantContactsData;

  if (phoneNumber) applicant.updatePhoneNumber(phoneNumber);
  if (email) applicant.email = email;
  if (rightsOpeningDate) applicant.rightsOpeningDate = rightsOpeningDate;

  return applicant;
};

const updateApplicantContactsData = (applicant, parsedApplicantContactsData) => {
  if (applicant.createdAt) {
    return updateExistingApplicantContactsData(applicant, parsedApplicantContactsData);
  }
  return updateNewApplicantContactsData(applicant, parsedApplicantContactsData);
};

export default updateApplicantContactsData;
