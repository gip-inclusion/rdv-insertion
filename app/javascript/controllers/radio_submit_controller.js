import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit", "radio"]

  connect() {
    this.toggleSubmit()
  }

  toggleSubmit() {
    this.submitTarget.disabled = !this.#hasSelectedRadio()
  }

  updateUrl(event) {
    const url = new URL(window.location)
    url.searchParams.set("category_configuration_id", event.target.value)
    window.history.replaceState({}, "", url)

    this.toggleSubmit()
  }

  #hasSelectedRadio() {
    return this.radioTargets.some(radio => radio.checked)
  }
}
