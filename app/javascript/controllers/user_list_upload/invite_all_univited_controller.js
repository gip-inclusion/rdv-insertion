import { Controller } from "@hotwired/stimulus";
import safeSwal from "../../lib/safeSwal";
import fetchApp from "../../lib/fetchApp";

export default class extends Controller {
  static targets = ["checkbox"]

  async createUserListUploadAndRedirect(event) {
    event.preventDefault()
    this.form = event.target
    const button = this.form.querySelector("button[type='submit']")
    await this.#setLoadingButton(button)
    await this.#fetchUninvitedUsers()
    if (this.userIds.length === 0) {
      safeSwal({
        title: "Tous les usagers sont déjà invités",
        text: "Tous les usagers ont déjà été invités sur cette catégorie",
        icon: "success"
      })
      return
    }
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
    url.searchParams.set("follow_up_statuses[]", "not_invited")
    try {
      const jsonResponse = await fetchApp(url.toString(), { parseJson: true })
      const { users } = jsonResponse
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
      const response = await fetchApp(this.form.action, {
        method: this.form.method,
        body: {
          user_ids: this.userIds,
          user_list_upload: {
            origin: "invite_all_uninvited_button",
            category_configuration_id: this.form.dataset.currentCategoryConfigurationId
          }
        }
      })

      if (response.ok) {
        /* eslint-disable-next-line camelcase */
        const { redirect_path } = await response.json()
        window.Turbo.visit(redirect_path)
      } else {
        const { errors } = await response.json()
        safeSwal({
          title: "Une erreur s'est produite lors de la création de la liste",
          text: errors.join(", "),
          icon: "error"
        })
        this.#resetButton()
      }
    } catch (error) {
      console.error(error)
      safeSwal({
        title: "Une erreur s'est produite lors de la création de la liste",
        text: "Veuillez réessayer ou contacter l'équipe RDV-Insertion",
        icon: "error"
      })
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