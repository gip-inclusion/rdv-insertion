import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { formId: String }

  connect() {
    if (this.#answered) this.element.remove()
  }

  hide(event) {
    if (event.detail.formId === this.formIdValue) this.element.remove()
  }

  get #answered() {
    return localStorage.getItem(`tally-answered-${this.formIdValue}`) === "true"
  }
}
