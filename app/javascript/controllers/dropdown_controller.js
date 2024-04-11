import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.button = this.element.querySelector("button")
    this.menu = this.element.querySelector(".dropdown-menu")
    this.input = this.element.querySelector("#participation_status")
    this.clickOutsideHandlerListener = this.clickOutsideHandler.bind(this)
    this.visible = false

    this.button.addEventListener("click", () => {
      this.toggle()
    })

    this.menu.querySelectorAll("a").forEach((link) => {
      link.addEventListener("click", (e) => {
        e.preventDefault()
        e.stopPropagation()
        this.input.value = link.dataset.value
        window.Turbo.navigator.submitForm(this.element)
      })
    })
  }

  toggle() {
    this.menu.classList.toggle("show")
    this.visible = !this.visible

    if (this.visible) {
      document.addEventListener("click", this.clickOutsideHandlerListener)
    } else {
      document.removeEventListener("click", this.clickOutsideHandlerListener)
    }
  }

  clickOutsideHandler(e) {
    if (!this.element.contains(e.target)) {
      this.toggle()
    }
  }
}
