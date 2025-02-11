// Equivalent of the ruby "parameterize" method
const parameterize = (string) =>
  string
    .replace(/[\n\r]+/g, " ")
    .trim()
    .replace(/ +(?= )/g, "")
    .replace(/'/g, "-")
    .toLowerCase()
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace("n°", "numero")
    .split(" ")
    .join("-");

const parameterizeObjectKeys = (object) =>
  Object.keys(object).reduce((res, key) => {
    res[parameterize(key)] = object[key];
    return res;
  }, {});

const parameterizeObjectValues = (object) =>
  Object.keys(object).reduce((res, key) => {
    res[key] = parameterize(object[key]);
    return res;
  }, {});

const parameterizeArray = (array) =>
  array.map((element) => parameterize(element));

export { parameterizeObjectKeys, parameterizeObjectValues, parameterizeArray, parameterize };
