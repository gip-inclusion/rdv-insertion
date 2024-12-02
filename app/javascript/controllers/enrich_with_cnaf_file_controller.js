import { Controller } from "@hotwired/stimulus";
import * as XLSX from "xlsx";
import { retrieveMissingColumnNames, retrieveSheetColumnNames, displayMissingColumnsWarning, validateFileFormat } from "../lib/fileParser";
import parseContactsData from "../lib/parseContactsData";

export default class extends Controller {
  static targets = ["input", "form"]

  connect() {
    this.userList = JSON.parse(this.element.dataset.userList)
  }

  async submit(event) {
    event.preventDefault()
    const file = event.target.files[0]

    if (file) {
      if(!validateFileFormat(file, this.#acceptedFileFormats())) {
        return
      }
      if (!await this.#readFile(file)) {
        return
      }

      this.rowsDataByUid = {}

      this.#retrieveRowsCnafData()

      this.formTarget.querySelector("input[name='rows_data_by_uid']").value = JSON.stringify(this.rowsDataByUid)

      await this.formTarget.requestSubmit()
    }
  }

  #acceptedFileFormats() {
    return this.inputTarget.accept.split(",").map((format) => format.trim())
  }

  #retrieveRowsCnafData() {
    this.userList.forEach((user) => {
      if (!user.affiliation_number && !user.nir) {
        return
      }
      const matchingCnafDataRow = this.cnafDataRows.find((cnafDataRow) =>
        // for affiliation number that have less than 7 digits, we fill the missing digits with 0 at the beginning
        (user.affiliation_number && cnafDataRow.MATRICULE && user.affiliation_number.toString().padStart(7, "0") === cnafDataRow.MATRICULE.toString().padStart(7, "0"))
          || (user.nir && cnafDataRow.NIR && user.nir.slice(0, 13) === cnafDataRow.NIR.slice(0, 13))
      )

      if (matchingCnafDataRow) {
        const parsedCnafData = parseContactsData(matchingCnafDataRow)
        this.rowsDataByUid[user.user_list_uid] = {
          cnaf_data: {
            email: parsedCnafData.email,
            phone_number: parsedCnafData.phoneNumber,
            rights_opening_date: parsedCnafData.rightsOpeningDate
          }
        }
      }
    })
  }

  #readFile(file) {
    const expectedContactsColumnNames = [
      "MATRICULE",
      "DATE DEBUT DROITS - DEVOIRS",
      "NUMERO TELEPHONE DOSSIER",
      "NUMERO TELEPHONE 2 DOSSIER",
      "ADRESSE ELECTRONIQUE DOSSIER",
    ];

    return new Promise((resolve) => {
      const reader = new FileReader();
      reader.onload = (event) => {
        const sheet = XLSX.read(event.target.result, {
          type: "string",
          cellDates: true,
          dateNF: "dd/mm/yyyy",
        }).Sheets.Sheet1;
        const sheetColumnNames = retrieveSheetColumnNames(sheet);
        const missingColumnNames = retrieveMissingColumnNames(sheetColumnNames, expectedContactsColumnNames);
        if (missingColumnNames.length > 0) {
          displayMissingColumnsWarning(missingColumnNames);
          resolve(false);
        } else {
          this.cnafDataRows = XLSX.utils.sheet_to_json(sheet, { raw: false });
          resolve(true);
        }
      };
      reader.readAsArrayBuffer(file);
    });
  }
}
