import { Controller } from "@hotwired/stimulus";
import Swal from "sweetalert2";
import * as XLSX from "xlsx";
import { retrieveMissingColumnNames, retrieveSheetColumnNames, displayMissingColumnsWarning, validateFileFormat } from "../lib/fileParser";
import parseContactsData from "../lib/parseContactsData";

export default class extends Controller {
  static targets = ["input", "form"]

  connect() {
    this.userRows = JSON.parse(this.element.dataset.userRows)
  }

  async submit(event) {
    event.preventDefault()
    const file = event.target.files[0]

    if (file) {
      if(!validateFileFormat(file, this.#acceptedFileFormats())) {
        this.inputTarget.value = ""
        return
      }
      if (!await this.#readFile(file)) {
        this.inputTarget.value = ""
        return
      }

      this.rowsCnafData = []

      this.#retrieveRowsCnafData()

      const existingInputs = this.formTarget.querySelectorAll("input[name^='rows_cnaf_data']")
      existingInputs.forEach(input => input.remove())

      if (this.rowsCnafData.length === 0) {
        Swal.fire({
          title: "Aucun usager trouvé",
          text: "Aucun usager trouvé dans le fichier CNAF",
          icon: "warning",
          confirmButtonText: "OK"
        })
        this.inputTarget.value = ""
        return
      }

      this.rowsCnafData.forEach((row) => {
        const uidInput = document.createElement("input")
        uidInput.type = "hidden"
        uidInput.name = "rows_cnaf_data[][uid]"
        uidInput.value = row.uid

        // Create separate inputs for each cnaf_data field
        const emailInput = document.createElement("input")
        emailInput.type = "hidden"
        emailInput.name = "rows_cnaf_data[][cnaf_data][email]"
        emailInput.value = row.cnaf_data.email

        const phoneInput = document.createElement("input")
        phoneInput.type = "hidden"
        phoneInput.name = "rows_cnaf_data[][cnaf_data][phone_number]"
        phoneInput.value = row.cnaf_data.phone_number

        const dateInput = document.createElement("input")
        dateInput.type = "hidden"
        dateInput.name = "rows_cnaf_data[][cnaf_data][rights_opening_date]"
        dateInput.value = row.cnaf_data.rights_opening_date

        this.formTarget.appendChild(uidInput)
        this.formTarget.appendChild(emailInput)
        this.formTarget.appendChild(phoneInput)
        this.formTarget.appendChild(dateInput)
      })

      await this.formTarget.requestSubmit()
    }
  }

  #acceptedFileFormats() {
    return this.inputTarget.accept.split(",").map((format) => format.trim())
  }

  #retrieveRowsCnafData() {
    this.userRows.forEach((userRow) => {
      if (!userRow.affiliation_number && !userRow.nir) {
        return
      }
      const matchingCnafDataRow = this.cnafDataRows.find((cnafDataRow) =>
        // for affiliation number that have less than 7 digits, we fill the missing digits with 0 at the beginning
        (userRow.affiliation_number && cnafDataRow.MATRICULE && userRow.affiliation_number.toString().padStart(7, "0") === cnafDataRow.MATRICULE.toString().padStart(7, "0"))
          || (userRow.nir && cnafDataRow.NIR && userRow.nir.slice(0, 13) === cnafDataRow.NIR.slice(0, 13))
      )

      if (matchingCnafDataRow) {
        const parsedCnafData = parseContactsData(matchingCnafDataRow)
        this.rowsCnafData.push({
          uid: userRow.uid,
          cnaf_data: {
            email: parsedCnafData.email,
            phone_number: parsedCnafData.phoneNumber,
            rights_opening_date: parsedCnafData.rightsOpeningDate
          }
        })
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
