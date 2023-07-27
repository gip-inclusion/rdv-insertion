const updateExistingApplicantContactsData = async (applicant, parsedApplicantContactsData) => {
  ["email", "rightsOpeningDate"].forEach((attributeName) => {
    const attribute = parsedApplicantContactsData[attributeName];
    if (attribute && applicant[attributeName] !== attribute) {
      applicant[`${attributeName}New`] = attribute;
    }
  });

  const { phoneNumber } = parsedApplicantContactsData;
  // since the phone are not formatted in the file we compare the 8 last digits
  if (phoneNumber && applicant.phoneNumber?.slice(-8) !== phoneNumber.slice(-8)) {
    applicant.phoneNumberNew = phoneNumber;
  }
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
