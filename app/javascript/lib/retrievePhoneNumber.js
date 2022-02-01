const retrievePhoneNumber = (applicantContactsData) => {
  const phoneNumber = applicantContactsData["NUMERO TELEPHONE DOSSIER"];
  const phoneNumber2 = applicantContactsData["NUMERO TELEPHONE 2 DOSSIER"];
  // We want to retrieve a mobile number if possible, but if there is none, we prefer retrieving a number rather than nothing
  if (phoneNumber?.startsWith("06") || phoneNumber?.startsWith("07")) {
    return phoneNumber;
  }
  if (phoneNumber2?.startsWith("06") || phoneNumber2?.startsWith("07")) {
    return phoneNumber2;
  }
  return phoneNumber;
};

export default retrievePhoneNumber;
