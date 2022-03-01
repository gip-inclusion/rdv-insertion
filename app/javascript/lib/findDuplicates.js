const findDuplicates = (arr) => [
  ...new Set(arr.filter((element, index, array) => array.indexOf(element) !== index)),
];

export default findDuplicates;
