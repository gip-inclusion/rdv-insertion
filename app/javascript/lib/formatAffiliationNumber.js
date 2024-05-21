const formatAffiliationNumber = (affiliationNumber) => {
  if (!affiliationNumber) return null;

  // we remove leading zeros
  const formattedNumber = affiliationNumber.replace(/^0+/, "");
  return truncateIfOnlyTrailingZeros(formattedNumber);
}

const truncateIfOnlyTrailingZeros = (str) =>
  str.length > 7 && str.slice(7).replace(/0/g, "").length === 0 ? str.slice(0, 7) : str;
;

export default formatAffiliationNumber;
