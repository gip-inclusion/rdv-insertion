import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  choose() {
    const selectedRadio = this.element.querySelector("input[type=radio]:checked")
    const url = selectedRadio.value

    if (url) {
      window.Turbo.visit(url)
    }
  }
}