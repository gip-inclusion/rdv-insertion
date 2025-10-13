import { Controller } from "@hotwired/stimulus"
import * as XLSX from "xlsx"
import { retrieveSheetColumnNames, retrieveMissingColumnNames, displayMissingColumnsWarning, validateFileFormat } from "../../lib/fileParser"
import { parameterizeObjectKeys, parameterizeObjectValues } from "../../lib/parameterize"
import { formatInput, formatAffiliationNumber, formatDateInput, formatAddress, formatRole, formatTitle, formatTags } from "../../lib/inputFormatters"

export default class extends Controller {
  static targets = ["dropZone", "input", "uploadedFileInfo", "fileName", "fileInputInstruction", "userCount", "submitButton", "warning"]

  connect() {
    this.fileConfigurationColumnAttributes = JSON.parse(this.element.dataset.fileConfigurationColumnAttributes)
    this.fileConfigurationSheetName = this.element.dataset.fileConfigurationSheetName
    this.categoryConfigurationId = this.element.dataset.categoryConfigurationId
  }

  handleDragOver(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.add("drag-over")
  }

  handleDragLeave(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.remove("drag-over")
  }

  async handleDrop(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.remove("drag-over")

    const file = event.dataTransfer.files[0]
    if (file) {
      this.dropZoneTarget.setAttribute("data-matomo-event", "rdvi_upload_select-file_drag-drop");
      await this.#processFile(file)
    }
  }

  async handleFileSelect(event) {
    const file = event.target.files[0]
    if (file) {
      await this.#processFile(file)
    }
  }

  openFilePicker() {
    this.inputTarget.click()
  }

  handleOpenPickerKeydown(event) {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault()
      this.openFilePicker()
    }
  }

  handleFileRemove() {
    this.#removeFileInput()
    this.#updateFileName("")
    this.#updateUserCount("")
    this.fileInputInstructionTarget.classList.remove("d-none")
    this.uploadedFileInfoTarget.classList.add("d-none")
  }

  async handleSubmit(event) {
    event.preventDefault()

    const button = this.submitButtonTarget
    const { form } = event.target

    await this.#setLoadingButton(button)

    this.userList = this.#transformRowsInUserList(this.rows)

    const payload = {
      file_name: this.fileNameTarget.textContent,
      category_configuration_id: this.categoryConfigurationId,
      origin: "file_upload",
      user_rows_attributes: this.userList
    }

    // Here we send the form as JSON instead of native form data
    // Because natively form data have a size limit that makes
    // upload fail whenever too many users are sent
    //
    // Sending this as JSON makes the payload sligthly
    // smaller and allows for any number of users to be sent
    try {
      const response = await fetch(form.action, {
        method: form.method,
        headers: {
          "Content-Type": "application/json",
          "Accept": "text/vnd.turbo-stream.html",
          "X-CSRF-Token": document.querySelector("meta[name=\"csrf-token\"]").content,
        },
        body: JSON.stringify(payload)
      })

      if (response.status === 200) {
        /* eslint-disable-next-line camelcase */
        const { redirect_path } = await response.json()
        window.Turbo.visit(redirect_path)
      } else {
        const html = await response.text()
        window.Turbo.renderStreamMessage(html)
        this.#resetForm()
      }
    } catch (err) {
      this.#resetForm()
    }
  }

  async #setLoadingButton(button) {
    this.originalButton = button

    // Create a new button element to replace the input
    const newButton = document.createElement("button")
    newButton.type = "submit"
    newButton.className = `${button.className} disabled`
    newButton.innerHTML = `
      <span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
      Chargement des données usagers...
    `
    this.loadingButton = newButton

    button.insertAdjacentElement("afterend", newButton)
    button.remove()
  }

  #resetForm() {
    this.handleFileRemove()
    if (this.loadingButton) {
      this.loadingButton.parentElement.appendChild(this.originalButton)
      this.originalButton.classList.add("disabled")
      this.loadingButton.remove()
    }
  }

  #transformRowsInUserList(rows) {
    const parameterizedColumnAttributes = parameterizeObjectValues(this.fileConfigurationColumnAttributes)
    return rows.map((row) => {
      return {
        first_name: formatInput(row[parameterizedColumnAttributes.first_name_column]),
        last_name: formatInput(row[parameterizedColumnAttributes.last_name_column]),
        affiliation_number: formatAffiliationNumber(formatInput(row[parameterizedColumnAttributes.affiliation_number_column])),
        role: formatRole(row[parameterizedColumnAttributes.role_column]),
        title: formatTitle(row[parameterizedColumnAttributes.title_column]),
        nir: formatInput(row[parameterizedColumnAttributes.nir_column]),
        department_internal_id: formatInput(row[parameterizedColumnAttributes.department_internal_id_column]),
        france_travail_id: formatInput(row[parameterizedColumnAttributes.france_travail_id_column]),
        tag_values: formatTags(row[parameterizedColumnAttributes.tags_column]),
        birth_date: formatDateInput(row[parameterizedColumnAttributes.birth_date_column]),
        birth_name: formatInput(row[parameterizedColumnAttributes.birth_name_column]),
        phone_number: formatInput(row[parameterizedColumnAttributes.phone_number_column]),
        email: formatInput(row[parameterizedColumnAttributes.email_column]),
        address: formatAddress(
          row[parameterizedColumnAttributes.address_first_field_column],
          row[parameterizedColumnAttributes.address_second_field_column],
          row[parameterizedColumnAttributes.address_third_field_column],
          row[parameterizedColumnAttributes.address_fourth_field_column],
          row[parameterizedColumnAttributes.address_fifth_field_column]
        ),
        rights_opening_date: formatDateInput(row[parameterizedColumnAttributes.rights_opening_date_column]),
        referent_email: formatInput(row[parameterizedColumnAttributes.referent_email_column]),
        organisation_search_terms: formatInput(row[parameterizedColumnAttributes.organisation_search_terms_column]),
      }
    })
  }

  async #processFile(file) {
    const acceptedFormats = this.inputTarget.accept.split(",").map((format) => format.trim())
    if (validateFileFormat(file, acceptedFormats)) {
      if (await this.#readFile(file)) {
        this.#setFileSelected(file)
      } else {
        this.#removeFileInput()
      }
    }
  }

  #removeFileInput() {
    this.inputTarget.value = ""
  }

  async #readFile(file) {
    return new Promise((resolve) => {
      const reader = new FileReader();
      reader.onload = (event) => {
        const workbook = XLSX.read(event.target.result, { type: "binary" });
        const sheet = workbook.Sheets[this.fileConfigurationSheetName] || workbook.Sheets[workbook.SheetNames[0]];
        const sheetColumnNames = retrieveSheetColumnNames(sheet);
        const missingColumnNames = retrieveMissingColumnNames(sheetColumnNames, Object.values(this.fileConfigurationColumnAttributes));
        if (missingColumnNames.length > 0) {
          displayMissingColumnsWarning(missingColumnNames);
          resolve(false);
        } else {
          this.rows = XLSX.utils.sheet_to_row_object_array(sheet);
          this.rows = this.rows.map((row) => parameterizeObjectKeys(row));

          resolve(true);
        }
      };
      reader.readAsArrayBuffer(file);
    });
  }

  #setFileSelected(file) {
    this.#updateFileName(file.name)
    this.#updateUserCount(this.rows.length)

    this.#toggleTooManyLinesWarning()
    this.fileInputInstructionTarget.classList.add("d-none")
    this.uploadedFileInfoTarget.classList.remove("d-none")
    if (this.rows.length > 0) {
      this.submitButtonTarget.classList.remove("disabled")
    }
  }

  #toggleTooManyLinesWarning() {
    if (this.rows.length > 500) {
      this.warningTarget.classList.remove("d-none")
    } else {
      this.warningTarget.classList.add("d-none")
    }
  }

  #updateFileName(name) {
    this.fileNameTarget.textContent = name
  }

  #updateUserCount(count) {
    this.userCountTarget.textContent = count > 0 ? `${count} usagers à importer` : "Aucun usager à importer"
  }
}
