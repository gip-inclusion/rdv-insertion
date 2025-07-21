import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    containerId: String,
  }

  connect() {
    console.log("matomo script tag");

    console.log("containerIdValue", this.containerIdValue);
    if (this.containerIdValue === "") {
      console.error("MATOMO_CONTAINER_ID is not set");
      return;
    }

    /* eslint no-underscore-dangle: "off" */
    window._mtm = window._mtm || [];
    window._mtm.push({ "mtm.startTime": new Date().getTime(), event: "mtm.Start" });
    const matomoScriptTag = document.createElement("script");
    matomoScriptTag.async = true;
    matomoScriptTag.src = `https://matomo.inclusion.beta.gouv.fr/js/container_${this.containerIdValue}.js`;

    const firstScriptTag = document.getElementsByTagName("script")[0];
    firstScriptTag.parentNode.insertBefore(matomoScriptTag, firstScriptTag);
  }
}
