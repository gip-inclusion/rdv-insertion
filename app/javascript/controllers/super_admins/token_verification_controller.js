import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["digitInput", "tokenInput"]

  connect() {
    if (this.digitInputTargets.length > 0) {
      this.digitInputTargets[0].focus()
    }
  }

  handleInput(event) {
    const value = event.target.value
    const index = parseInt(event.target.dataset.index, 10)

    if (value && index < this.digitInputTargets.length - 1) {
      this.digitInputTargets[index + 1].focus()
      return
    }

    this.checkAndSubmit()
  }

  handlePaste(event) {
    event.preventDefault()
    const digits = event.clipboardData.getData("text")

    digits.split("").forEach((digit, i) => {
      if (i < this.digitInputTargets.length) {
        this.digitInputTargets[i].value = digit
      }
    })

    // Focus the next empty input or the last one
    const nextEmptyIndex = Math.min(digits.length, this.digitInputTargets.length - 1)
    this.digitInputTargets[nextEmptyIndex].focus()

    this.checkAndSubmit()
  }


  handleKeydown(event) {
    const value = event.target.value
    const index = parseInt(event.target.dataset.index, 10)

    if (event.key === "Backspace" && !value && index > 0) {
      this.digitInputTargets[index - 1].focus()
    }
  }

  checkAndSubmit() {
    const allFilled = this.digitInputTargets.every(input => typeof input.value === "string" && input.value.length === 1)

    if (allFilled) {
      const token = this.digitInputTargets.map(input => input.value).join("")
      this.tokenInputTarget.value = token
      this.element.submit()
    }
  }
}