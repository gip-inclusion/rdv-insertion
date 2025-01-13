import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  initialize() {
    // Bind the `refresh` function to ensure it's the same reference
    this.handleTurboRender = this.refresh.bind(this);
    document.addEventListener("turbo:render", this.handleTurboRender);
  }

  connect() {
    this.refresh();
  }

  disconnect() {
    // Remove the `turbo:render` listener and restore the progress bar
    document.removeEventListener("turbo:render", this.handleTurboRender);
  }

  refresh() {
    setTimeout(() => {
      // Trigger Turbo visit
      window.Turbo.visit(window.location.href, { action: "replace" });
    }, 1000);
  }
}
