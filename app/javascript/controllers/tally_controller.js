import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  async showPopup() {
    if (this.#hasAlreadyAnswered || !this.element.dataset.tallyFormId) return

    await this.#loadScript()
    this.#displayForm()
  }

  #loadScript() {
    return new Promise((resolve) => {
      if (!document.querySelector("script#tally-script")) {
        const script = document.createElement("script");
        script.src = "https://tally.so/widgets/embed.js";
        script.id = "tally-script"
        script.onload = resolve
        document.head.appendChild(script);
      } else {
        resolve();
      }
    })
  }

  #displayForm() {
    setTimeout(() => {
      window.Tally.openPopup(this.element.dataset.tallyFormId, {
        onSubmit: () => {
          this.#hasAlreadyAnswered = true

          // Give time for the user to read success message in Tally's popup
          setTimeout(() => window.Tally.closePopup(this.element.dataset.tallyFormId), 1000);
        }
      })
    }, this.element.dataset.tallyDelayInMs || 0)
  }

  set #hasAlreadyAnswered(value) {
    localStorage.setItem(this.#hasAlreadyAnsweredKey, value)
  }

  get #hasAlreadyAnswered() {
    return !!localStorage.getItem(this.#hasAlreadyAnsweredKey)
  }

  get #hasAlreadyAnsweredKey() {
    return `tally-answered-${this.element.dataset.tallyFormId}`
  }
}
