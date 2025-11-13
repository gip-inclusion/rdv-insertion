import { Controller } from "@hotwired/stimulus";
import Cookies from "js-cookie";

export default class extends Controller {
  static values = {
    containerId: String,
  }

  connect() {
    if (this.containerIdValue === "") {
      /* eslint-disable-next-line no-console */
      console.error("MATOMO_CONTAINER_ID is not set");
      return;
    }

    /* eslint no-underscore-dangle: "off" */
    window._mtm = window._mtm || [];

    // Initial page view tracking before Matomo script loads
    this.trackPageView();

    window._mtm.push({ "mtm.startTime": new Date().getTime(), event: "mtm.Start" });

    const matomoScriptTag = document.createElement("script");
    matomoScriptTag.async = true;
    matomoScriptTag.src = `https://matomo.inclusion.beta.gouv.fr/js/container_${this.containerIdValue}.js`;

    const firstScriptTag = document.getElementsByTagName("script")[0];
    firstScriptTag.parentNode.insertBefore(matomoScriptTag, firstScriptTag);

    this.trackPageView = this.trackPageView.bind(this);
    document.addEventListener("turbo:load", this.trackPageView);
  }

  disconnect() {
    document.removeEventListener("turbo:load", this.trackPageView);
  }

  trackPageView() {
    const routePattern = Cookies.get("matomo_page_url") || window.location.pathname;

    window._mtm = window._mtm || [];
    window._mtm.push({
      customPageUrl: routePattern
    });
  }
}
