import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  spin() {
    this.element.querySelector("button .spinner-border").classList.remove("d-none")
  }
  
  stopSpin() {
    this.element.querySelector("button .spinner-border").classList.add("d-none")
  }
}
