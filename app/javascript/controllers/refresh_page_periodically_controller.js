import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  initialize() {
    this.handleTurboRender = this.refresh.bind(this);
    document.addEventListener("turbo:render",  this.handleTurboRender);
  }

  connect() {
    this.refresh();
  }

  disconnect() {
    document.removeEventListener("turbo:render", this.handleTurboRender);
  }

  refresh() {
    setTimeout(() => {
      window.Turbo.visit(window.location.href, { action: "replace" });
    }, 1000);
  }
}
