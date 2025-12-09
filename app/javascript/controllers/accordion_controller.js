import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "content", "icon"]

  static values = { openIndex: { type: Number, default: -1 } }

  connect() {
    if (this.openIndexValue >= 0) {
      this.#updateDisplay()
    }
  }

  toggle(event) {
    const clickedIndex = parseInt(event.currentTarget.dataset.index, 10)
    // -1 means no item is open
    this.openIndexValue = this.openIndexValue === clickedIndex ? -1 : clickedIndex
    this.#updateDisplay()
  }

  #updateDisplay() {
    this.itemTargets.forEach((_, index) => {
      const content = this.contentTargets[index]
      const icon = this.iconTargets[index]

      if (index === this.openIndexValue) {
        content.classList.remove("d-none")
        icon.classList.add("ri-arrow-up-s-line")
        icon.classList.remove("ri-arrow-down-s-line")
      } else {
        content.classList.add("d-none")
        icon.classList.remove("ri-arrow-up-s-line")
        icon.classList.add("ri-arrow-down-s-line")
      }
    })
  }
}
