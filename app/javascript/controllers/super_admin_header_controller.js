import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    if (localStorage.getItem("super-admin-header-closed") === "true")
      this.hide()
    else
      this.show();    
  }

  toggle() {
    if (this.element.classList.contains("hidden"))
      this.show()
    else
      this.hide();
  }

  show() {
    this.element.classList.remove("hidden");
    localStorage.setItem("super-admin-header-closed", "false");
  }

  hide() {
    this.element.classList.add("hidden");
    localStorage.setItem("super-admin-header-closed", "true");
  }
}