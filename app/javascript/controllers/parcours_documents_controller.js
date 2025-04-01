import { Controller } from "@hotwired/stimulus";
import safeSwal from "../lib/safeSwal";

export default class extends Controller {
  fetchFile() {
    this.element.querySelector("input[type=file]").click()
  }

  submit(event) {
    const file = event.target.files[0]
    const maxSize = Number(this.element.dataset.maxSize)

    if (file && file.size < maxSize) {
      window.Turbo.navigator.submitForm(this.element)
      this.clearFileInput();
    } else if (file) {
      safeSwal({
        title: "Ce fichier est trop lourd",
        text: `Veuillez sélectionner un fichier dont la taille ne dépasse pas ${(maxSize / 1000000).toFixed()} Mo`,
        icon: "warning",
      })
    }
  }

  clearFileInput() {
    this.element.querySelector("input[type=file]").value = null;
  }

  spin() {
    this.element.querySelector("button .spinner-border").classList.remove("d-none")
    this.element.querySelector("button i").classList.add("d-none")
  }

  stopSpin() {
    this.element.querySelector("button .spinner-border").classList.add("d-none")
    this.element.querySelector("button i").classList.remove("d-none")
  }

  toggleEditDate() {
    this.element.querySelector(".date-update").classList.toggle("d-none")
    this.element.querySelector(".edit-date-button").classList.toggle("d-none")
    this.element.querySelector(".document-date-value").classList.toggle("d-none")
    this.element.querySelector("input[type=date]").focus()
  }
}
