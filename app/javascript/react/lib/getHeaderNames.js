import * as XLSX from "xlsx";

const getHeaderNames = (sheet) => {
  const header = [];
  const columnCount = XLSX.utils.decode_range(sheet["!ref"]).e.c + 1;
  for (let i = 0; i < columnCount; i += 1) {
    if (sheet[`${XLSX.utils.encode_col(i)}1`] !== undefined) {
      header[i] = sheet[`${XLSX.utils.encode_col(i)}1`].v;
    }
  }
  return header;
};

export default getHeaderNames;
