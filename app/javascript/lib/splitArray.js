const splitArray = (array, filterFunction) => {
  const pass = [];
  const fail = [];
    for (let i = 0; i < array.length; i += 1)
      if (filterFunction(array[i])) {
        pass.push(array[i]);
      }
      else {
        fail.push(array[i]);
      }
    return [pass, fail];
}


export default splitArray;
