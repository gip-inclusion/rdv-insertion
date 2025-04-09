import { Controller } from "@hotwired/stimulus";
import Cookies from "js-cookie";

export default class extends Controller {
  static targets = ["dropdown", "button"];

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
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  #saveNotificationsReadTimestampInCookies() {
    const notificationItems = this.dropdownTarget.querySelectorAll(".notification-center-dropdown-body-item");

    if (notificationItems.length > 0) {
      const firstNotificationCreatedAt = notificationItems[0].dataset.created_at;
      const lastNotificationCreatedAt = notificationItems[notificationItems.length - 1].dataset.created_at;
      
      const existingFirst = Cookies.get("most_recent_notification_read");
      const existingLast = Cookies.get("oldest_notification_read");
      
      // Update first timestamp only if it's more recent (greater) than existing
      if (!existingFirst || parseInt(firstNotificationCreatedAt, 10) > parseInt(existingFirst, 10)) {
        Cookies.set("most_recent_notification_read", firstNotificationCreatedAt);
      }
      
      // Update last timestamp only if it's older (smaller) than existing
      if (!existingLast || parseInt(lastNotificationCreatedAt, 10) < parseInt(existingLast, 10)) {
        Cookies.set("oldest_notification_read", lastNotificationCreatedAt);
      }
    }
  }
  
  toggle() {
    if (this.dropdownTarget.classList.contains("d-none")) {
      this.buttonTarget.classList.remove("has-notification");
    }
    this.dropdownTarget.classList.toggle("d-none");
  }

  close() {
    this.dropdownTarget.classList.add("d-none");
  }

  markAllAsRead() {
    this.dropdownTarget.classList.add("d-none");
    this.buttonTarget.classList.remove("has-notification");

    const veryOldDate = new Date(0);
    const now = new Date();
    
    Cookies.set("oldest_notification_read", Math.floor(veryOldDate.getTime() / 1000));
    Cookies.set("most_recent_notification_read", Math.floor(now.getTime() / 1000));
  }
}
