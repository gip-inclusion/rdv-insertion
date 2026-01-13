import { Controller } from "@hotwired/stimulus"

// Accordion controller for expandable/collapsible sections.
// Tracks which sections are expanded and toggles visibility on click.
// Also used as a stepper: enableAndOpenAll() unlocks all sections, activates badges and enables submit.
export default class extends Controller {
  static targets = ["content", "icon", "badge", "submitButton"]

  connect() {
    this.expandedSections = new Set()
    this.#detectInitialState()
    this.#openFromAnchor()
  }

  #openFromAnchor() {
    const anchorId = window.location.hash.replace("#", "")
    if (!anchorId) return

    const item = this.element.querySelector(`#${anchorId}`)
    const index = item?.querySelector("[data-index]")?.dataset.index
    if (!index) return

    this.expandedSections.add(parseInt(index, 10))
    this.#updateDisplay()
    setTimeout(() => item.scrollIntoView({ block: "start" }), 0)
  }

  toggle(event) {
    const header = event.currentTarget
    if (header.classList.contains("disabled")) return

    const index = parseInt(header.dataset.index, 10)

    if (this.expandedSections.has(index)) {
      this.expandedSections.delete(index)
    } else {
      this.expandedSections.add(index)
    }

    this.#updateDisplay()
  }

  enableAndOpenAll() {
    this.#enableAllHeaders()
    this.#activateBadges()
    this.#enableSubmitButton()
    this.contentTargets.forEach((_, index) => this.expandedSections.add(index))
    this.#updateDisplay()
  }

  #detectInitialState() {
    this.contentTargets.forEach((content, index) => {
      if (!content.classList.contains("d-none")) {
        this.expandedSections.add(index)
      }
    })
  }

  #enableAllHeaders() {
    this.element.querySelectorAll("[data-index].disabled").forEach(header => {
      header.classList.remove("disabled")
    })
  }

  #activateBadges() {
    this.badgeTargets.forEach(badge => {
      badge.classList.remove("inactive")
      badge.classList.add("active")
    })
  }

  #enableSubmitButton() {
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = false
    }
  }

  #updateDisplay() {
    this.contentTargets.forEach((content, index) => {
      const icon = this.iconTargets[index]
      const isOpen = this.expandedSections.has(index)

      content?.classList.toggle("d-none", !isOpen)
      icon?.classList.toggle("ri-arrow-up-s-line", isOpen)
      icon?.classList.toggle("ri-arrow-down-s-line", !isOpen)
    })
  }
}
