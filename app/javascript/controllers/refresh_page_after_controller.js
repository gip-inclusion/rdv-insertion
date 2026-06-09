import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { delay: Number };

  connect() {
    this.timeout = setTimeout(() => {
      window.Turbo.visit(window.location.href, { action: "replace" });
    }, this.delayValue);
  }

  disconnect() {
    clearTimeout(this.timeout);
  }
}
