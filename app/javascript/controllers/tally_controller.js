import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  async showPopup() {
    await this.loadScript()
    setTimeout(() => {
      window.Tally.openPopup(this.element.dataset.tallyFormId)
    }, this.element.dataset.tallyDelayInMs || 0)
  }

  loadScript() {
    return new Promise((resolve) => {
      if (!document.querySelector("script[src=\"https://tally.so/widgets/embed.js\"]")) {
        const script = document.createElement("script");
        script.src = "https://tally.so/widgets/embed.js";
        script.onload = resolve
        document.head.appendChild(script);
      } else {
        resolve();
      }
    })
  }
}
