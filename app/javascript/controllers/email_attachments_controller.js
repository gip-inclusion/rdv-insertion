import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "attachmentsList"]

  connect() {
    this.attachedFiles = []
  }

  add(event) {
    event.preventDefault()
    this.fileInputTarget.click()

    this.fileInputTarget.addEventListener("change", () => {
      // Create a Set to ensure uniqueness by file name, then convert back to array
      const existingFileNames = new Set(this.attachedFiles.map(file => file.name));
      const uniqueNewFiles = Array.from(this.fileInputTarget.files).filter(file => !existingFileNames.has(file.name));

      this.attachedFiles = [...this.attachedFiles, ...uniqueNewFiles];
      this.syncAttachedFiles()
      this.renderAttachmentsList()
    })
  }

  syncAttachedFiles() {
    const dt = new DataTransfer()

    this.attachedFiles.forEach(file => dt.items.add(file))
    this.fileInputTarget.files = dt.files;
  }

  renderAttachmentsList() {
    this.attachmentsListTarget.innerHTML = ""
    Array.from(this.attachedFiles).forEach(file => {
      const fileDiv = document.createElement("div")
      fileDiv.classList.add("d-flex", "align-items-center", "text-dark-blue", "gap-2", "mb-2", "attachment-item")
      
      const icon = document.createElement("i")
      icon.classList.add("ri-file-text-line")
      fileDiv.appendChild(icon)

      const fileName = document.createElement("span")
      fileName.innerText = file.name
      fileDiv.appendChild(fileName)

      const removeButton = document.createElement("button")
      removeButton.setAttribute("type", "button")
      removeButton.setAttribute("data-action", "email-attachments#remove")
      removeButton.classList.add("btn", "p-0")

      const closeIcon = document.createElement("i")
      closeIcon.classList.add("ri-close-line")
      removeButton.appendChild(closeIcon)

      fileDiv.appendChild(removeButton)
      this.attachmentsListTarget.appendChild(fileDiv)
    })
  }

  remove(event) {
    event.preventDefault()

    const fileDiv = event.target.closest(".attachment-item")
    fileDiv.remove()

    this.attachedFiles = this.attachedFiles.filter(file => !fileDiv.textContent.includes(file.name))

    this.syncAttachedFiles()
  }
}
