const findDuplicates = (arr) => [...new Set(arr.filter((e, i, a) => a.indexOf(e) !== i))];

export default findDuplicates;
