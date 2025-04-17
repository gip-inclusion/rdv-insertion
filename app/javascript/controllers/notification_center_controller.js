import { Controller } from "@hotwired/stimulus"
import Cookies from "js-cookie"

export default class extends Controller {
  static targets = ["dropdown", "button"]

  connect() {
    this.handleClickOutside = this.#handleClickOutside.bind(this)
    document.addEventListener("click", this.handleClickOutside)
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }

    document.removeEventListener("click", this.handleClickOutside)
  }

  #handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  toggle() {
    if (this.dropdownTarget.classList.contains("d-none")) {
      this.buttonTarget.classList.remove("has-notification")
    }
    this.dropdownTarget.classList.toggle("d-none")
  }

  close() {
    this.dropdownTarget.classList.add("d-none")
  }

  markAllAsRead() {
    this.close()
    this.buttonTarget.classList.remove("has-notification")

    const veryOldDate = new Date(0)
    const now = new Date()
    
    Cookies.set("oldest_notification_read", Math.floor(veryOldDate.getTime() / 1000))
    Cookies.set("most_recent_notification_read", Math.floor(now.getTime() / 1000))
  }
}
