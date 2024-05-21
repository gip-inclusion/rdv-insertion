import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  navigate(event) {
    if (event.target.tagName === "INPUT" || event.target.tagName === "BUTTON" || event.target.tagName === "I") {
      return;
    }

    const userLinkUrl = new URL(window.location.protocol + window.location.host + this.resolvePathFromTarget(event.target));
    window.location.href = userLinkUrl;
  }

  resolvePathFromTarget(target) {
    let path = this.data.get("path");

    if (target.dataset.linkPath || target.parentElement.dataset.linkPath) {
      path = target.dataset.linkPath || target.parentElement.dataset.linkPath;
    }

    return path
  }
}
