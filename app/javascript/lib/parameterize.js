// Equivalent of the ruby "parameterize" method
const parameterizeObjectKeys = (object) =>
  Object.keys(object).reduce((res, key) => {
    res[
      key
        .replace(/[\n\r]+/g, " ")
        .trim()
        .replace(/ +(?= )/g, "")
        .replace(/'/g, "-")
        .toLowerCase()
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "")
        .replace("n°", "numero")
        .split(" ")
        .join("-")
    ] = object[key];
    return res;
  }, {});

const parameterizeObjectValues = (object) =>
  Object.keys(object).reduce((res, key) => {
    res[key] =
      object[key]
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
    return res;
  }, {});

export { parameterizeObjectKeys, parameterizeObjectValues };
