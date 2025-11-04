import { Controller } from "@hotwired/stimulus";

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
    const routePattern = this.rewriteUrlToRoutePattern(window.location.pathname);

    window._mtm = window._mtm || [];
    window._mtm.push({
      customPageUrl: routePattern
    });
  }

  rewriteUrlToRoutePattern(path) {
    // Remove query parameters
    let routePattern = path.split("?")[0];

    // Replace /resource_name/id patterns automatically
    routePattern = routePattern.replace(/\/([a-z_]+)\/([\d]+|[a-f0-9-]{8,})/g, (match, resourceName) => {
      // Special case: /r/uuid for invitation links
      if (resourceName === "r") {
        return "/r/:uuid";
      }

      const singularName = this.singularize(resourceName);
      return `/${resourceName}/:${singularName}_id`;
    });

    return routePattern;
  }

  singularize(word) {
    if (word.endsWith("ies")) {
      return `${word.slice(0, -3)}y`; // companies -> company
    }
    if (word.endsWith("s")) {
      return word.slice(0, -1); // users -> user
    }

    return word; // already singular or unknown
  }
}
