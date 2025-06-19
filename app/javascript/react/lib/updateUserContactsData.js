const updateExistingUserContactsData = async (user, parsedUserContactsData) => {
  ["email"].forEach((attributeName) => {
    const attribute = parsedUserContactsData[attributeName];
    if (attribute && user[attributeName] !== attribute) {
      user[`${attributeName}New`] = attribute;
    }
  });

  const { phoneNumber } = parsedUserContactsData;
  // since the phone are not formatted in the file we compare the 8 last digits
  if (phoneNumber && user.phoneNumber?.slice(-8) !== phoneNumber.slice(-8)) {
    user.phoneNumberNew = phoneNumber;
  }
  return user;
};

const updateNewUserContactsData = (user, parsedUserContactsData) => {
  const { phoneNumber } = parsedUserContactsData;
  const { email } = parsedUserContactsData;

  if (phoneNumber) user.updatePhoneNumber(phoneNumber);
  if (email) user.email = email;

  return user;
};

const updateUserContactsData = (user, parsedUserContactsData) => {
  if (user.createdAt) {
    return updateExistingUserContactsData(user, parsedUserContactsData);
  }
  return updateNewUserContactsData(user, parsedUserContactsData);
};

export default updateUserContactsData;
