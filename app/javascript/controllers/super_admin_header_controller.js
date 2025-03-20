import { Controller } from "@hotwired/stimulus";
import Cookies from "js-cookie";

export default class extends Controller {
  toggle() {
    if (this.element.classList.contains("hidden")) {
      this.show()
    } else {
      this.hide();
    }
  }

  show() {
    this.element.classList.remove("hidden");
    Cookies.set("super_admin_header_closed", "false", { path: "/", expires: 365 });
  }

  hide() {
    this.element.classList.add("hidden");
    Cookies.set("super_admin_header_closed", "true", { path: "/", expires: 365 });
  }
}