import { Controller } from "@hotwired/stimulus";
import Cookies from "js-cookie";

export default class extends Controller {
  static targets = ["dropdown", "button"];
  
  toggle() {
    if (this.dropdownTarget.classList.contains("d-none")) {
      Cookies.set("notification-center-opened", new Date().toISOString(), {  expires: 1 });
      this.buttonTarget.classList.remove("has-notification");
    }
    this.dropdownTarget.classList.toggle("d-none");
  }

  close() {
    this.dropdownTarget.classList.add("d-none");
  }

  markAllAsRead() {
    this.dropdownTarget.classList.add("d-none");
    Cookies.set("notification-center-read", new Date().toISOString(), { expires: 1 });
  }
}
