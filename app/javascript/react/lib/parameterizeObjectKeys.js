// Returns the object with the keys having line breaks removed and parameterized
const parameterizeObjectKeys = (object) =>
  Object.keys(object).reduce((res, key) => {
    res[
      key
        .replace(/[\n\r]+/g, " ")
        .trim()
        .replace(/ +(?= )/g, "")
        .replace(/'/g, "-")
        .toLowerCase()
        .replace("n°", "numero")
        .split(" ")
        .join("-")
    ] = object[key];
    return res;
  }, {});

export default parameterizeObjectKeys;
