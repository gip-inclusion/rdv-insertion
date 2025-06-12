import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "button",
    "dropdown",
  ]

  connect() {
    window.addEventListener("click", (e) => {
      if (e.target !== this.buttonTarget && !this.dropdownTarget.contains(e.target) && this.isOpen()){
        this.toggle()
      }
    })
  }

  toggle() {
    this.dropdownTarget.classList.toggle("d-block")
    this.buttonTarget.ariaExpanded = this.isOpen()
  }

  isOpen() {
    return this.dropdownTarget.classList.contains("d-block")
  }
}
