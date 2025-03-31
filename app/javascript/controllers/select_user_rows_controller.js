import { Controller } from "@hotwired/stimulus";
import Rails from "@rails/ujs";
import Cookies from "js-cookie";
import DOMPurify from "dompurify";

export default class extends Controller {
  static targets = ["checkbox", "invitationFormatOption"]

  connect() {
    /* eslint-disable prefer-destructuring */
    this.userListUploadId = this.element.dataset.userListUploadId
    this.attributeToToggle = this.element.dataset.attributeToToggle
    /* eslint-enable prefer-destructuring */
  }

  toggleAll(event) {
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = checkbox.disabled ? false : event.target.checked
    })
    Cookies.set(
      `checkbox_to_select_all_${this.attributeToToggle}_checked_${this.userListUploadId}`,
      event.target.checked,
      { path: "/", expires: 0.01 } // ~10 minutes
    )
    this.#batchUpdateUserRows(this.attributeToToggle)
  }

  toggleSelect(event) {
    const { userRowId } = event.target.dataset
    const isChecked = event.target.checked

    const url = `/user_list_uploads/${this.userListUploadId}/user_rows/${userRowId}`

    this.#updateRow(url, this.attributeToToggle, isChecked)
  }

  #batchUpdateUserRows() {
    const url = `/user_list_uploads/${this.userListUploadId}/user_rows/batch_update`

    // Create a form to submit
    const form = document.createElement("form")
    form.method = "post"
    form.action = url
    form.innerHTML = DOMPurify.sanitize(`
      <input type="hidden" name="authenticity_token" value="${document.querySelector("meta[name='csrf-token']").content}">
    `)

    this.checkboxTargets.forEach(checkbox => {
      const { userRowId } = checkbox.dataset
      const isChecked = checkbox.checked

      // Create input for row ID
      const idInput = document.createElement("input")
      idInput.type = "hidden"
      idInput.name = "user_rows[][id]"
      idInput.value = userRowId

      // Create input for the attribute value
      const attributeInput = document.createElement("input")
      attributeInput.type = "hidden"
      attributeInput.name = `user_rows[][${this.attributeToToggle}]`
      attributeInput.value = isChecked

      form.appendChild(idInput)
      form.appendChild(attributeInput)
    })

    // Submit the form
    document.body.appendChild(form)
    Rails.fire(form, "submit")
    document.body.removeChild(form)
  }

  #updateRow(url, attribute, value) {
    const form = document.createElement("form")
    form.method = "post"
    form.action = url
    form.innerHTML = DOMPurify.sanitize(`
      <input type="hidden" name="_method" value="patch">
      <input type="hidden" name="authenticity_token" value="${document.querySelector("meta[name='csrf-token']").content}">
      <input type="hidden" name="user_row[${attribute}]" value="${value}">
    `)

    document.body.appendChild(form)
    Rails.fire(form, "submit");
    document.body.removeChild(form)
  }

  handleFormatOptionChange(event) {
    const selectedFormats = this.invitationFormatOptionTargets.filter(option => option.checked).map(option => option.dataset.format)

    Cookies.set(
      `selected_invitation_formats_${this.userListUploadId}`,
      JSON.stringify(selectedFormats),
      { path: "/", expires: 0.01 }
    )

    if (event.target.checked) {
      // we just reload the page if we are enabling the invitation format
      window.Turbo.visit(window.location.href, { action: "replace" });
      return
    }

    this.checkboxTargets.forEach(checkbox => {
      const isInvitable = selectedFormats.length > 0 &&
        (selectedFormats.includes("email") && checkbox.dataset.userEmail) ||
        (selectedFormats.includes("sms") && checkbox.dataset.userPhone)

      if (!isInvitable) {
        checkbox.checked = false
        checkbox.disabled = true
      }
    })

    this.#batchUpdateUserRows()
  }
}

