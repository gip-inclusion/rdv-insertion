import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "checkbox" ]

  static values = { paramName: String }

  apply() {
    const selectedValues = this.checkboxTargets
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.value)

    const url = new URL(window.location.href)
    url.searchParams.delete(this.paramNameValue)

    if (selectedValues.length > 0) {
      const paramKey = this.isMultiple() ? `${this.paramNameValue}[]` : this.paramNameValue
      selectedValues.forEach(value => url.searchParams.append(paramKey, value))
    }

    window.location.href = url.toString()
  }
  
  isMultiple() {
    return this.checkboxTargets[0].type === "checkbox"
  }
} 