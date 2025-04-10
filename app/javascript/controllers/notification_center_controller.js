import { Controller } from "@hotwired/stimulus"
import Cookies from "js-cookie"

export default class extends Controller {
  static targets = ["dropdown", "button"]

  connect() {
    this.observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (mutation.addedNodes.length > 0) {
          this.#saveNotificationsReadTimestampInCookies()
        }
      })
    })

    this.observer.observe(this.dropdownTarget, {
      childList: true,
      subtree: true
    })

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

  #saveNotificationsReadTimestampInCookies() {
    const notificationItems = this.dropdownTarget.querySelectorAll(".notification-center-dropdown-body-item")

    if (notificationItems.length > 0) {
      const firstNotificationCreatedAt = parseInt(notificationItems[0].dataset.created_at, 10)
      const lastNotificationCreatedAt = parseInt(notificationItems[notificationItems.length - 1].dataset.created_at, 10)
      
      const existingFirst = parseInt(Cookies.get(this.mostRecentNotificationReadCookieName), 10)
      const existingLast = parseInt(Cookies.get(this.oldestNotificationReadCookieName), 10)
      
      if (!existingFirst || firstNotificationCreatedAt > existingFirst) {
        Cookies.set(this.mostRecentNotificationReadCookieName, firstNotificationCreatedAt + 1)
      }
      
      if (!existingLast || lastNotificationCreatedAt < existingLast) {
        Cookies.set(this.oldestNotificationReadCookieName, lastNotificationCreatedAt - 1)
      }
    }
  }

  get mostRecentNotificationReadCookieName() {
    return `most_recent_notification_read_on_${this.element.dataset.organisationId}`
  }

  get oldestNotificationReadCookieName() {
    return `oldest_notification_read_on_${this.element.dataset.organisationId}`
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
