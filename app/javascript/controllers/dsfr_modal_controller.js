import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // setTimeout needed to ensure the modal renders visually after Turbo Frame load
    // Without it, the dialog element exists in DOM but doesn't display
    setTimeout(() => {
      this.element.showModal()
      this.element.classList.add("fr-modal--opened")
    }, 0)
    this.element.addEventListener("click", this.#handleBackdropClick)
  }

  close() {
    this.element.classList.remove("fr-modal--opened")
    this.element.close()
  }

  #handleBackdropClick = (event) => {
    if (event.target === this.element) {
      this.close()
    }
  }

  disconnect() {
    this.element.removeEventListener("click", this.#handleBackdropClick)
  }
}
