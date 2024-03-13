import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  navigate(event) {
    if (event.target.tagName === "INPUT" || event.target.tagName === "BUTTON") { return; }

    this.userLinkUrl = new URL(window.location.protocol + window.location.host + this.data.get("path"));
    window.location.href = this.userLinkUrl;
  }
}
