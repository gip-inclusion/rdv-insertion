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
    // ESC key triggers 'cancel' event, we prevent default and call close manually
    this.element.addEventListener("cancel", this.#handleCancel)
  }

  close() {
    this.element.classList.remove("fr-modal--opened")
    this.element.close()
  }

  // For native <dialog>, backdrop clicks have event.target === dialog element
  // Content clicks have event.target === clicked element
  #handleBackdropClick = (event) => {
    if (event.target === this.element) {
      this.close()
    }
  }

  #handleCancel = () => {
    this.element.classList.remove("fr-modal--opened")
  }

  disconnect() {
    this.element.removeEventListener("click", this.#handleBackdropClick)
    this.element.removeEventListener("cancel", this.#handleCancel)
  }
}
