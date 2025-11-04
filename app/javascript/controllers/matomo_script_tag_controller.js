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

    // Replace numeric IDs with named identifiers, add more replacements as needed
    routePattern = routePattern.replace(/\/organisations\/\d+/, "/organisations/:organisation_id");
    routePattern = routePattern.replace(/\/departments\/\d+/, "/departments/:department_id");
    routePattern = routePattern.replace(/\/user_list_uploads\/[a-f0-9-]+/, "/user_list_uploads/:user_list_upload_id");
    routePattern = routePattern.replace(/\/user_rows\/\d+/, "/user_rows/:user_row_id");
    routePattern = routePattern.replace(/\/agents\/\d+/, "/agents/:agent_id");
    routePattern = routePattern.replace(/\/follow_ups\/\d+/, "/follow_ups/:follow_up_id");
    routePattern = routePattern.replace(/\/participations\/\d+/, "/participations/:participation_id");
    routePattern = routePattern.replace(/\/file_configurations\/\d+/, "/file_configurations/:file_configuration_id");
    routePattern = routePattern.replace(/\/r\/[a-f0-9-]+/, "/r/:uuid");

    // General replacement for any remaining numeric IDs
    routePattern = routePattern.replace(/\/\d+/g, "/:id");

    return routePattern;
  }
}
