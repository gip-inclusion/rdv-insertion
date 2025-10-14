import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input" ]

  static values = { paramName: String }

  apply() {
    const selectedValues = this.inputTargets
      .filter(input => input.checked)
      .map(input => input.value)

    const url = new URL(window.location.href)
    url.searchParams.delete(this.paramNameValue)
    url.searchParams.delete(`${this.paramNameValue}[]`)

    if (selectedValues.length > 0) {
      const paramKey = this.isMultiple() ? `${this.paramNameValue}[]` : this.paramNameValue
      selectedValues.forEach(value => url.searchParams.append(paramKey, value))
    }

    window.location.href = url.toString()
  }

  isMultiple() {
    return this.inputTargets[0].type === "checkbox"
  }
}
