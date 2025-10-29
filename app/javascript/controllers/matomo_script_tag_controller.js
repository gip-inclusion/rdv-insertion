import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    containerId: String,
    customUrl: String,
  }

  connect() {
    if (this.containerIdValue === "") {
      /* eslint-disable-next-line no-console */
      console.error("MATOMO_CONTAINER_ID is not set");
      return;
    }

    /* eslint no-underscore-dangle: "off" */
    window._mtm = window._mtm || [];
    window._mtm.push({ "mtm.startTime": new Date().getTime(), event: "mtm.Start" });

    // Push custom URL to mask IDs in URLs
    if (this.customUrlValue) {
      window._mtm.push({
        customPageUrl: this.customUrlValue
      });
    }

    const matomoScriptTag = document.createElement("script");
    matomoScriptTag.async = true;
    matomoScriptTag.src = `https://matomo.inclusion.beta.gouv.fr/js/container_${this.containerIdValue}.js`;

    const firstScriptTag = document.getElementsByTagName("script")[0];
    firstScriptTag.parentNode.insertBefore(matomoScriptTag, firstScriptTag);
  }
}
