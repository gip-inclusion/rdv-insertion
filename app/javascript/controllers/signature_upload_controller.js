import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "attachedSection", "notAttachedSection", "removeField", "filename", "originalLink"]

  removeSignature() {
    this.removeFieldTarget.value = "true"
    this.fileInputTarget.value = ""
    this.#clearFilename()
    this.#showFilenameDisplay()
    this.#updateSectionVisibility(false)
  }

  connect() {
    this.fileInputTarget.addEventListener("change", (event) => {
      if (event.target.files.length > 0) {
        this.#handleNewFileSelection(event.target.files[0])
      }
    })
  }

  #handleNewFileSelection(file) {
    this.removeFieldTarget.value = "false"
    this.#updateFilename(file.name)
    this.#showFilenameDisplay()
    this.#updateSectionVisibility(true)
  }

  #updateSectionVisibility(isAttached) {
    if (isAttached) {
      this.notAttachedSectionTarget.classList.add("d-none")
      this.attachedSectionTarget.classList.remove("d-none")
    } else {
      this.attachedSectionTarget.classList.add("d-none")
      this.notAttachedSectionTarget.classList.remove("d-none")
    }
  }

  #showFilenameDisplay() {
    if (this.hasOriginalLinkTarget) {
      this.originalLinkTarget.classList.add("d-none")
    }
    if (this.hasFilenameTarget) {
      this.filenameTarget.classList.remove("d-none")
    }
  }

  #updateFilename(filename) {
    if (this.hasFilenameTarget) {
      this.filenameTarget.textContent = filename
    }
  }

  #clearFilename() {
    if (this.hasFilenameTarget) {
      this.filenameTarget.textContent = ""
    }
  }
}
