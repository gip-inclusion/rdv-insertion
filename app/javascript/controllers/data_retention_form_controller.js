import { Controller } from "@hotwired/stimulus"
import safeSwal from "../lib/safeSwal";

export default class extends Controller {
  static targets = ["input"]

  async submit() {
    const response = await fetch(this.element.action, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
      },
      body: JSON.stringify({
        organisation: {
          data_retention_duration: this.inputTarget.value
        }
      })
    })

    if (!response.ok) {
      safeSwal({
        title: "Erreur",
        text: "Une erreur est survenue lors de la mise à jour de la durée de conservation des données.",
        icon: "error"
      })
    }
  }
}
