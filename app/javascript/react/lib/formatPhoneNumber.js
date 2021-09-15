// we add a "0" in front of the number because it happens often
// that the 0 is missing due to Excel formatting
const formatPhoneNumber = (phoneNumber) => {
  if (!phoneNumber || phoneNumber.length === 0) {
    return null;
  }

  if (phoneNumber[0] === "+") {
    return phoneNumber;
  }
  return phoneNumber[0] !== "0" ? `0${phoneNumber}` : phoneNumber;
};

export default formatPhoneNumber;
