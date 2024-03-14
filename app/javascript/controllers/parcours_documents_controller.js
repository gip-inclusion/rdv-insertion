import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  fetchFile() {
    this.element.querySelector("input[type=file]").click()
  }

  submit(event) {
    if (event.target.value.length > 0) {
      window.Turbo.navigator.submitForm(this.element)
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

  editDate() {
    this.element.querySelector("input[type=date]").classList.remove("d-none")
    this.element.querySelector(".edit-date-button").classList.add("d-none")
    this.element.querySelector(".document-date-value").classList.add("d-none")
  }

  updateDate() {
    const date = this.element.querySelector("input[type=date]").value
    this.element.querySelector(".document-date-value").innerText = date
    this.element.querySelector("input[type=date]").classList.add("d-none")
    this.element.querySelector(".edit-date-button").classList.remove("d-none")
    this.element.querySelector(".document-date-value").classList.remove("d-none")
  }
}
