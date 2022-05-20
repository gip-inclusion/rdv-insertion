const updateExistingApplicantContactsData = async (applicant, parsedApplicantContactsData) => {
  ["email", "phoneNumber", "rightsOpeningDate"].forEach((attributeName) => {
    const attribute = parsedApplicantContactsData[attributeName];
    if (attribute && applicant[attributeName] !== attribute) {
      applicant[`${attributeName}New`] = attribute;
    }
  });
  return applicant;
};

const updateNewApplicantContactsData = (applicant, phoneNumber, email, rightsOpeningDate) => {
  if (applicant.phoneNumber == null && phoneNumber) {
    applicant.updatePhoneNumber(phoneNumber);
  }

  if (applicant.email == null && email) {
    applicant.email = email;
  }

  if (applicant.rightsOpeningDate == null && rightsOpeningDate) {
    applicant.rightsOpeningDate = rightsOpeningDate;
  }

  return applicant;
};

const updateApplicantContactsData = (applicant, parsedApplicantContactsData) => {
  const { phoneNumber } = parsedApplicantContactsData;
  const { email } = parsedApplicantContactsData;
  const { rightsOpeningDate } = parsedApplicantContactsData;
  if (applicant.createdAt) {
    return updateExistingApplicantContactsData(applicant, parsedApplicantContactsData);
  }
  return updateNewApplicantContactsData(applicant, phoneNumber, email, rightsOpeningDate);
};

export default updateApplicantContactsData;
