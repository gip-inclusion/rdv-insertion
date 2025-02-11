import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["searchInput"]

  initialize() {
    this.timeout = null
  }

  search() {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      const url = new URL(this.element.action)
      const params = new URLSearchParams(window.location.search)

      if (this.searchInputTarget.value.trim()) {
        params.set("search_query", this.searchInputTarget.value)
      } else {
        params.delete("search_query")
      }

      url.search = params.toString()
      window.Turbo.visit(url, { action: "replace" })
    }, 200)
  }
}
