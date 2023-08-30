import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.element.querySelector("button[type=submit]").disabled = true
    this.element.querySelector("input[type=\"text\"]").addEventListener("keyup", (event) => {
      this.element.querySelector("button[type=submit]").disabled = !event.target.value
    })
  }
  
  
  clear() {
    this.element.querySelector("input[type=\"text\"]").value = "";
    this.element.querySelector("button[type=submit]").disabled = true
  }
}
