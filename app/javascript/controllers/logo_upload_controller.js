import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dropZone", "input", "previewContainer", "previewImage", "fileName", "placeholder", "removeField"]

  handleDragOver(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.add("drag-over")
  }

  handleDragLeave(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.remove("drag-over")
  }

  handleDrop(event) {
    event.preventDefault()
    this.dropZoneTarget.classList.remove("drag-over")

    const file = event.dataTransfer.files[0]
    if (file && this.#isValidImage(file)) {
      this.#processFile(file)
    }
  }

  handleFileSelect(event) {
    const file = event.target.files[0]
    if (file && this.#isValidImage(file)) {
      this.#processFile(file)
    }
  }

  handleFileRemove(event) {
    event.preventDefault()
    this.#clearPreview()
    this.removeFieldTarget.value = "true"
  }

  handleOpenPickerKeydown(event) {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault()
      this.inputTarget.click()
    }
  }

  #isValidImage(file) {
    const validTypes = ["image/png", "image/jpeg"]
    return validTypes.includes(file.type)
  }

  #processFile(file) {
    const dataTransfer = new DataTransfer()
    dataTransfer.items.add(file)
    this.inputTarget.files = dataTransfer.files

    const reader = new FileReader()
    reader.onload = (e) => {
      this.previewImageTarget.src = e.target.result
      this.fileNameTarget.textContent = file.name
      this.previewContainerTarget.classList.remove("d-none")
      this.placeholderTarget.classList.add("d-none")
    }
    reader.readAsDataURL(file)

    this.removeFieldTarget.value = "false"
  }

  #clearPreview() {
    this.inputTarget.value = ""
    this.previewContainerTarget.classList.add("d-none")
    this.placeholderTarget.classList.remove("d-none")
  }
}
