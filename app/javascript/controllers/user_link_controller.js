import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.userLinkUrl = new URL(window.location.protocol + window.location.host + this.data.get("path"));
  }

  navigate() {
    window.location.href = this.userLinkUrl;
  }
}
