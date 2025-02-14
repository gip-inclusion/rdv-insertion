import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit", "radio"]

  connect() {
    this.submitTarget.disabled = !this.#hasSelectedRadio()
  }

  toggleSubmit() {
    this.submitTarget.disabled = false
  }

  #hasSelectedRadio() {
    return this.radioTargets.some(radio => radio.checked)
  }
}