import { Controller } from "@hotwired/stimulus";
import safeSwal from "../../lib/safeSwal";

export default class extends Controller {
  static targets = ["checkbox"]

  async createUserListUploadAndRedirect(event) {
    event.preventDefault()
    this.form = event.target
    const button = this.form.querySelector("button[type='submit']")
    await this.#setLoadingButton(button)
    await this.#fetchUninvitedUsers()
    await this.#createUserListUpload()
  }

  async #setLoadingButton(button) {
    this.originalButton = button

    // Create a new button element to replace the input
    const newButton = document.createElement("button")
    newButton.type = "submit"
    newButton.className = `${button.className} disabled`
    newButton.innerHTML = `
      <span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
      Création de la liste en cours...
    `
    this.loadingButton = newButton

    button.insertAdjacentElement("afterend", newButton)
    button.remove()
  }

  async #fetchUninvitedUsers() {
    const url = new URL(window.location.href)
    url.searchParams.set("skip_pagination", "true")
    url.searchParams.set("ids_only", "true")
    console.log(url.toString())
    try {
      const response = await fetch(url.toString(), {
        method: "GET",
        headers: { "Content-Type": "application/json", "Accept": "application/json" }
      })
      const { users } = await response.json()
      this.userIds = users.map(user => user.id)
    } catch (error) {
      safeSwal({
        title: "Une erreur s'est produite lors de la récupération des usagers",
        text: error.message,
        icon: "error"
      })
    }
  }

  async #createUserListUpload() {
    try {
      const response = await fetch(this.form.action, {
        method: this.form.method,
        headers: {
          "Content-Type": "application/json",
          "Accept": "text/vnd.turbo-stream.html",
          "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
        },
        body: JSON.stringify({ user_ids: this.userIds, origin: "invite_all_uninvited_button" })
      })
      if (response.ok) {
        /* eslint-disable-next-line camelcase */
        const { redirect_path } = await response.json()
        window.Turbo.visit(redirect_path)
      } else {
        const html = await response.text()
        window.Turbo.renderStreamMessage(html)
        this.#resetButton()
      }
    } catch (error) {
      console.error(error)
      this.#resetButton()
    }
  }

  #resetButton() {
    if (this.loadingButton) {
      this.loadingButton.parentElement.appendChild(this.originalButton)
      this.loadingButton.remove()
    }
  }
}