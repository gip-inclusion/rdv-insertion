import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.input = this.element.querySelector("input")
    this.dropdown = this.element.querySelector(".autocomplete")
    this.disableAutocomplete()

    this.input.addEventListener("keyup", () => this.triggerAutocomplete())
    this.element.parentElement.addEventListener("submit", () => this.disableAutocomplete())
    this.element.querySelectorAll("button").forEach((button) => {
      button.addEventListener("click", (event) => this.selectValue(event))
    })
  }

  selectValue(event) {
    this.input.value = event.target.innerText
    this.disableAutocomplete()
  }

  triggerAutocomplete() {
    const matches = this.values().filter((value) => value.toLowerCase().includes(this.input.value.toLowerCase()))
    
    if (this.input.value.length > 0 && matches.length > 0) {
      this.dropdown.classList.remove("d-none")
      this.element.querySelectorAll("button").forEach((button) => {
        if (matches.includes(button.innerText)) {
          button.classList.remove("d-none")
        } else {
          button.classList.add("d-none")
        }
      })
    } else {
      this.disableAutocomplete()
    }
  }

  disableAutocomplete() {
    this.dropdown.classList.add("d-none")
  }

  values() {
    return [...this.element.querySelectorAll("button")].map((button) => button.innerText)
  }
}
