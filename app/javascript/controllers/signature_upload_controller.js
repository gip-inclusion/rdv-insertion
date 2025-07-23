import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "fileInput", "removeField"]
  
  connect() {
    this.fileInputTarget.addEventListener("change", (event) => {
      if (event.target.files.length > 0) {
        this.handleFileSelection(event.target.files[0])
      }
    })
  }
  
  removeSignature() {
    this.removeFieldTarget.value = "true"
    this.fileInputTarget.value = ""
    this.updateState("NO_SIGNATURE")
  }
  
  handleFileSelection(file) {
    this.removeFieldTarget.value = "false"
    this.updateFilename(file.name)
    this.updateState("NEW_FILE")
  }
  
  updateState(state) {
    this.containerTarget.dataset.signatureState = state
  }
  
  updateFilename(filename) {
    const filenameEl = this.containerTarget.querySelector("[data-filename]")
    if (filenameEl) {
      filenameEl.textContent = filename
    }
  }
}
