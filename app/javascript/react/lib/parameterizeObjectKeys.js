// Returns the object with the keys having line breaks removed and parameterized
export const parameterizeObjectKeys = object => {
  return Object.keys(object).reduce((res, key) => {
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
};
