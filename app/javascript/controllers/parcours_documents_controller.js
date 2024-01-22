import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  enableSubmit(event) {
    if (event.target.value.length > 0) {
      this.element.querySelector("button").removeAttribute("disabled")
    }
  }

  spin() {
    this.element.querySelector("button .spinner-border").classList.remove("d-none")
    this.element.querySelector("button i").classList.add("d-none")
  }
  
  stopSpin() {
    this.element.querySelector("button .spinner-border").classList.add("d-none")
    this.element.querySelector("button i").classList.remove("d-none")
  }
}
